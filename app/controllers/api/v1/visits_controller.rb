module Api
    module V1
      class VisitsController < Api::V1::BaseController
        before_action :set_visit, only: [:show, :update, :destroy]
        before_action :ensure_valid_restaurant, only: [:create, :update]

        def index
          @pagy, @visits = pagy(current_user.visits.includes(:restaurant, :contacts))
          render json: {
            visits: @visits.map { |visit| VisitSerializer.new(visit).to_h },
            pagination: pagy_metadata(@pagy)
          }
        end

        def show
          render json: VisitSerializer.new(@visit).to_h
        end

        def create
          @visit = current_user.visits.build(visit_params)

          if @visit.save
            if params[:images].present?
              begin
                process_images
                render json: VisitSerializer.new(@visit).to_h, status: :created
              rescue StandardError => e
                @visit.destroy  # Rollback the visit creation if image processing fails
                render json: { error: 'Image processing failed' }, status: :unprocessable_entity
              end
            else
              render json: VisitSerializer.new(@visit).to_h, status: :created
            end
          else
            render json: { errors: @visit.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          @visit = current_user.visits.find(params[:id])
          if @visit.update(visit_params)
            render json: VisitSerializer.new(@visit).to_h
          else
            render json: { errors: @visit.errors.full_messages }, status: :unprocessable_entity
          end
          rescue ActiveRecord::RecordInvalid => e
            render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        end

        def destroy
          @visit.destroy
          head :no_content
        end

        private

        def set_visit
          @visit = current_user.visits.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Visit not found' }, status: :not_found
        end

        def visit_params
          params.require(:visit).permit(:date, :title, :notes, :restaurant_id, :rating, :price_paid, :price_paid_currency, contact_ids: []).tap do |whitelisted|
            if whitelisted[:price_paid].present?
              whitelisted[:price_paid] = Money.from_amount(whitelisted[:price_paid].to_f, whitelisted[:price_paid_currency] || 'USD')
            end
          end
        end

        def process_images
          ImageHandlingService.process_images(@visit, params[:images])
        end

        def ensure_valid_restaurant
          return if params[:visit].blank? || params[:visit][:restaurant_id].blank?
          unless current_user.restaurants.exists?(params[:visit][:restaurant_id])
            render json: { error: 'Invalid restaurant' }, status: :unprocessable_entity
          end
        end

        def convert_to_money(amount, currency)
          Money.from_amount(amount.to_f, currency || 'USD')
        end
      end
    end
  end
