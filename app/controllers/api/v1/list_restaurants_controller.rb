module Api
  module V1
    class ListRestaurantsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_list

      def create
        unless Current.organization
          render_unauthorized
          return
        end

        begin
          restaurant = Restaurant.find(params[:restaurant_id])
          @list.restaurants << restaurant
          render json: ListSerializer.render_success(@list, include_restaurants: true)
        rescue ActiveRecord::RecordNotFound
          render json: {
            status: "error",
            errors: [ {
              code: "not_found",
              detail: "Restaurant not found"
            } ]
          }, status: :not_found
        rescue ActiveRecord::RecordInvalid => e
          render json: BaseSerializer.render_validation_errors(e.record),
                 status: :unprocessable_entity
        rescue => e
          render_error(e.message)
        end
      end

      def destroy
        unless Current.organization
          render_unauthorized
          return
        end

        begin
          restaurant = @list.restaurants.find(params[:id])
          @list.restaurants.delete(restaurant)
          head :no_content
        rescue ActiveRecord::RecordNotFound
          render json: {
            status: "error",
            errors: [ {
              code: "not_found",
              detail: "Restaurant not found in list"
            } ]
          }, status: :not_found
        rescue => e
          render_error(e.message)
        end
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
        unless Current.organization
          render_unauthorized
          return
        end

        # First, find the list
        @list = List.find(params[:list_id])
        
        # Check if the list is editable by the current organization
        # This includes both owned lists and shared lists with edit permission
        unless @list.editable_by?(Current.organization)
          # Check if this is a shared list with the current organization
          share = Share.where(
            shareable: @list,
            target_organization: Current.organization,
            status: :accepted
          ).first
          
          # If there's no share or the permission is not edit, return not found
          if share.nil? || share.permission != "edit"
            render json: {
              status: "error",
              errors: [ {
                code: "not_found",
                detail: "List not found"
              } ]
            }, status: :not_found
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: "error",
          errors: [ {
            code: "not_found",
            detail: "List not found"
          } ]
        }, status: :not_found
      end
    end
  end
end
