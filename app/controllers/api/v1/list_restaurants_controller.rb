module Api
  module V1
    class ListRestaurantsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_list

      def create
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

      def destroy
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

      private

      def set_list
        @list = List.accessible_by(current_user).find(params[:list_id])
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
