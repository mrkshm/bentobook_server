module Api
  module V1
    class GoogleRestaurantsController < Api::V1::BaseController
      def show
        google_restaurant = GoogleRestaurant.find_by!(google_place_id: params[:id])
        render json: GoogleRestaurantSerializer.render_success(google_restaurant)
      rescue ActiveRecord::RecordNotFound
        render_error("Google restaurant not found", status: :not_found)
      end

      def create
        google_restaurant = GoogleRestaurant.find_or_initialize_by_place_id(google_restaurant_params)

        if google_restaurant.save
          render json: GoogleRestaurantSerializer.render_success(google_restaurant), status: :created
        else
          render_error(google_restaurant.errors.full_messages.join(", "))
        end
      rescue StandardError => e
        render_error(e.message)
      end

      private

      def google_restaurant_params
        params.require(:google_restaurant).permit(
          :name,
          :google_place_id,
          :address,
          :city,
          :latitude,
          :longitude,
          :google_rating,
          :street,
          :postal_code,
          :country,
          :phone,
          :website
        )
      end

      def render_error(message, status = :unprocessable_entity, pointer = nil)
        render json: BaseSerializer.render_error(message, status, pointer), status: status
      end
    end
  end
end
