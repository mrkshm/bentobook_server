module Api
  module V1
    class ListsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_list, only: [ :update, :destroy ]

      def index
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end
        
        Rails.logger.debug "=== DEBUG: ListsController#index ==="
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        Rails.logger.debug "Include shared: #{params[:include]&.include?("shared")}"
        
        begin
          if params[:include]&.include?("shared")
            # Include lists shared with the current organization
            Rails.logger.debug "Getting owned and shared lists"
            owned_lists = Current.organization.lists
            Rails.logger.debug "Owned lists: #{owned_lists.count}"
            shared_lists = Current.organization.shared_lists
            Rails.logger.debug "Shared lists: #{shared_lists.count}"
            
            # Convert to ActiveRecord relation instead of array
            lists = List.where(id: (owned_lists.pluck(:id) + shared_lists.pluck(:id)))
          else
            # Only include lists owned by the current organization
            Rails.logger.debug "Getting only owned lists"
            lists = Current.organization.lists
          end
          
          Rails.logger.debug "Total lists: #{lists.count}"

          if lists.empty?
            render json: ListSerializer.render_collection(
              [],
              pagy: {
                current_page: 1,
                total_pages: 0,
                total_count: 0
              }
            )
          else
            begin
              per_page = (params[:per_page] || 25).to_i
              pagy, records = pagy(lists, limit: per_page)
              render json: ListSerializer.render_collection(
                records,
                pagy: {
                  current_page: pagy.page,
                  total_pages: pagy.pages,
                  total_count: pagy.count
                }
              )
            rescue Pagy::OverflowError
              # If page is too high, return last page
              per_page = (params[:per_page] || 25).to_i
              last_page = (lists.count.to_f / per_page).ceil
              pagy, records = pagy(lists, limit: per_page, page: last_page)
              render json: ListSerializer.render_collection(
                records,
                pagy: {
                  current_page: pagy.page,
                  total_pages: pagy.pages,
                  total_count: pagy.count
                }
              )
            end
          end
        rescue => e
          Rails.logger.error "Error in index: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render_error(e.message)
        end
      end

      def show
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end
        
        Rails.logger.debug "=== DEBUG: ListsController#show ==="
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        Rails.logger.debug "List ID: #{params[:id]}"
        
        begin
          # Find list either owned by or shared with the current organization
          list = List.find(params[:id])
          Rails.logger.debug "Found list: #{list.inspect}"
          
          # Check if the list is viewable by the current organization
          viewable = list.viewable_by?(Current.organization)
          Rails.logger.debug "List viewable by organization? #{viewable}"
          
          if viewable
            render json: ListSerializer.render_success(list)
          else
            Rails.logger.debug "List not viewable by organization"
            render json: {
              status: "error",
              errors: [ {
                code: "not_found",
                detail: "List not found"
              } ]
            }, status: :not_found
          end
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.error "List not found: #{e.message}"
          render json: {
            status: "error",
            errors: [ {
              code: "not_found",
              detail: "List not found"
            } ]
          }, status: :not_found
        rescue => e
          Rails.logger.error "Error in show: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render_error(e.message)
        end
      end

      def create
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end
        
        Rails.logger.debug "=== DEBUG: ListsController#create ==="
        Rails.logger.debug "Current.organization: #{Current.organization.inspect}"
        Rails.logger.debug "Params: #{params.inspect}"
        
        begin
          list = Current.organization.lists.build(list_params.merge(creator: current_user))
          Rails.logger.debug "Built list: #{list.inspect}"
          Rails.logger.debug "List valid? #{list.valid?}"
          Rails.logger.debug "List errors: #{list.errors.full_messages}" unless list.valid?
          
          if list.save
            render json: ListSerializer.render_success(list), status: :created
          else
            Rails.logger.debug "List save failed: #{list.errors.full_messages}"
            render json: BaseSerializer.render_validation_errors(list), status: :unprocessable_entity
          end
        rescue => e
          Rails.logger.error "Error in create: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render_error(e.message)
        end
      end

      def update
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end
        
        if @list.update(list_params)
          render json: ListSerializer.render_success(@list)
        else
          render json: BaseSerializer.render_validation_errors(@list), status: :unprocessable_entity
        end
      rescue => e
        render_error(e.message)
      end

      def destroy
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end
        
        @list.destroy
        head :no_content
      rescue => e
        render_error(e.message)
      end

      private
      
      def render_unauthorized
        render json: {
          status: "error",
          errors: [ {
            code: "unauthorized",
            detail: "You need to sign in or sign up before continuing."
          } ]
        }, status: :unauthorized
      end

      def set_list
        # Return early if Current.organization is nil
        unless Current.organization
          render_unauthorized
          return
        end
        
        # Only allow modifying lists owned by the current organization
        @list = Current.organization.lists.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: "error",
          errors: [ {
            code: "not_found",
            detail: "List not found"
          } ]
        }, status: :not_found
      end

      def list_params
        params.require(:list).permit(:name, :description, :visibility, :premium, :position)
      end
    end
  end
end
