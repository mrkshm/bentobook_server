module Api
  module V1
    class VisitsController < Api::V1::BaseController
      before_action :set_visit, only: [ :show, :update, :destroy ]
      before_action :ensure_valid_restaurant, only: [ :create, :update ]

      def index
        base_scope = Current.organization.visits
          .select("visits.*")
          .includes(
            restaurant: { cuisine_type: {} },
            contacts: {}
          )

        visits_scope = VisitQuery.new(
          base_scope,
          search: params[:search],
          order_by: params[:order_by],
          order_direction: params[:order_direction],
          organization: Current.organization
        ).call

        if visits_scope.empty?
          render json: VisitSerializer.render_collection(
            [],
            pagy: {
              current_page: 1,
              total_pages: 0,
              total_count: 0,
              per_page: (params[:per_page] || 10).to_s
            }
          )
        else
          begin
            per_page = (params[:per_page] || 10).to_i
            @pagy, @visits = pagy(visits_scope, limit: per_page)

            render json: VisitSerializer.render_collection(
              @visits,
              pagy: {
                current_page: @pagy.page,
                total_pages: @pagy.pages,
                total_count: @pagy.count,
                per_page: per_page.to_s
              }
            )
          rescue Pagy::OverflowError
            # If page is out of bounds, return the last page
            last_page = (visits_scope.count.to_f / per_page).ceil
            @pagy, @visits = pagy(visits_scope, page: last_page)
            render json: VisitSerializer.render_collection(
              @visits,
              pagy: {
                current_page: @pagy.page,
                total_pages: @pagy.pages,
                total_count: @pagy.count,
                per_page: per_page.to_s
              }
            )
          end
        end
      rescue StandardError => e
        Rails.logger.error "Error in visits#index: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render_error("Failed to fetch visits", :internal_server_error)
      end

      def show
        visit = Current.organization.visits.includes(:contacts, :images).find(params[:id])
        render json: VisitSerializer.render_success(visit)
      rescue ActiveRecord::RecordNotFound
        render_error("Visit not found", :not_found)
      rescue StandardError => e
        Rails.logger.error("Error in visits#show: #{e.message}")
        render_error("Failed to retrieve visit", :internal_server_error)
      end

      def create
        visit = Current.organization.visits.build(visit_params)

        ActiveRecord::Base.transaction do
          if visit.save
            if params[:images].present?
              result = ImageProcessorService.new(visit, params[:images]).process
              unless result.success?
                raise StandardError, result.error
              end
            end
            render json: VisitSerializer.render_success(visit), status: :created
          else
            render_error(visit.errors.full_messages)
          end
        end
      rescue StandardError => e
        visit&.destroy if visit&.persisted?
        render_error("Failed to create visit: #{e.message}")
      end

      def update
        ActiveRecord::Base.transaction do
          if @visit.update(visit_params)
            if params[:images].present?
              result = ImageProcessorService.new(@visit, params[:images]).process
              unless result.success?
                raise StandardError, result.error
              end
            end
            render json: VisitSerializer.render_success(@visit)
          else
            render_error(@visit.errors.full_messages)
          end
        end
      rescue StandardError => e
        render_error("Failed to update visit: #{e.message}")
      end

      def destroy
        if @visit.destroy
          head :no_content
        else
          render_error("Failed to delete visit")
        end
      rescue ActiveRecord::RecordNotFound
        render_error("Visit not found", :not_found)
      rescue StandardError => e
        Rails.logger.error("Error in visits#destroy: #{e.message}")
        render_error("Failed to delete visit", :internal_server_error)
      end

      private

      def set_visit
        @visit = Current.organization.visits.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Visit not found", :not_found)
      end

      def visit_params
        params.require(:visit).permit(
          :date,
          :title,
          :notes,
          :restaurant_id,
          :rating,
          :price_paid_cents,
          :price_paid_currency,
          contact_ids: []
        )
      end

      def ensure_valid_restaurant
        restaurant_id = params.dig(:visit, :restaurant_id)
        return if restaurant_id.blank?

        unless Current.organization.restaurants.exists?(restaurant_id)
          render json: BaseSerializer.render_error(
            "Invalid restaurant",
            :invalid_restaurant
          ), status: :unprocessable_entity
        end
      end

      def render_error(message, status = :unprocessable_entity)
        render json: {
          status: "error",
          errors: [ {
            code: "unprocessable_entity",
            detail: message
          } ],
          meta: { timestamp: Time.current.iso8601 }
        }, status: status
      end
    end
  end
end
