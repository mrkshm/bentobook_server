module Api
  module V1
    class RestaurantsController < Api::V1::BaseController
      include Pagy::Backend

      before_action :set_restaurant, only: [ :show, :update, :destroy, :add_tag, :remove_tag ]

      def index
        restaurants_scope = current_user.restaurants.with_google.includes(:visits, :cuisine_type, :tags)
        query = RestaurantQuery.new(restaurants_scope, search_params)

        @pagy, @restaurants = pagy(query.call, items: params.fetch(:per_page, 10))

        render_collection(
          @restaurants,
          pagy: @pagy,
          meta: {
            sorting: {
              field: search_params[:order_by] || RestaurantQuery::DEFAULT_ORDER[:field],
              direction: search_params[:order_direction] || RestaurantQuery::DEFAULT_ORDER[:direction]
            }
          }
        )
      rescue StandardError => e
        render_error(e.message)
      end

      def show
        render_success(@restaurant)
      rescue StandardError => e
        render_error(e.message)
      end

      def create
        restaurant = nil

        ActiveRecord::Base.transaction do
          restaurant = build_restaurant

          unless restaurant.save
            return render_error(restaurant.errors.full_messages.join(", "))
          end

          if restaurant_params[:images].present?
            process_images(restaurant, restaurant_params[:images])
          end
        end

        render json: RestaurantSerializer.render_success(restaurant), status: :created
      rescue StandardError => e
        render_error(e.message)
      end

      def update
        ActiveRecord::Base.transaction do
          if restaurant_params[:images].present?
            process_images(@restaurant, restaurant_params[:images])
          end

          if @restaurant.update(restaurant_params.except(:images))
            render_success(@restaurant)
          else
            render_error(@restaurant.errors.full_messages.join(", "))
          end
        end
      rescue StandardError => e
        render_error(e.message)
      end

      def destroy
        if @restaurant.destroy
          head :no_content
        else
          render_error(@restaurant.errors.full_messages.join(", "))
        end
      rescue StandardError => e
        render_error(e.message)
      end

      def add_tag
        @restaurant.tag_list.add(params[:tag])

        if @restaurant.save
          render_success(@restaurant)
        else
          render_error(@restaurant.errors.full_messages.join(", "))
        end
      rescue StandardError => e
        render_error(e.message)
      end

      def remove_tag
        @restaurant.tag_list.remove(params[:tag])

        if @restaurant.save
          render_success(@restaurant)
        else
          render_error(@restaurant.errors.full_messages.join(", "))
        end
      rescue StandardError => e
        render_error(e.message)
      end

      private

      def set_restaurant
        @restaurant = current_user.restaurants.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Restaurant not found", status: :not_found)
      end

      def build_restaurant
        # Create restaurant with basic attributes only
        restaurant = current_user.restaurants.new(
          name: restaurant_params[:name],
          notes: restaurant_params[:notes],
          rating: restaurant_params[:rating].present? ? restaurant_params[:rating].to_i : nil,
          price_level: restaurant_params[:price_level]
        )

        # Set cuisine type
        cuisine_type_name = restaurant_params[:cuisine_type_name].presence || "uncategorized"
        restaurant.cuisine_type = CuisineType.find_or_create_by!(name: cuisine_type_name.downcase)

        # Handle tags if present
        if restaurant_params[:tag_list].present?
          restaurant.tag_list = restaurant_params[:tag_list]
        end

        # Create or find google restaurant
        if restaurant_params[:google_place_id].present?
          restaurant.google_restaurant = GoogleRestaurant.find_or_create_by!(
            google_place_id: restaurant_params[:google_place_id]
          ) do |gr|
            gr.name = restaurant_params[:name]
            gr.address = restaurant_params[:address]
            gr.city = restaurant_params[:city]
            gr.latitude = restaurant_params[:latitude]&.to_d
            gr.longitude = restaurant_params[:longitude]&.to_d
            gr.google_rating = restaurant_params[:rating]  # Keep the float rating in google_restaurant
          end
        else
          restaurant.build_google_restaurant(
            name: restaurant_params[:name],
            address: restaurant_params[:address],
            city: restaurant_params[:city],
            latitude: restaurant_params[:latitude]&.to_d,
            longitude: restaurant_params[:longitude]&.to_d,
            google_rating: restaurant_params[:rating],  # Keep the float rating in google_restaurant
            google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}"  # Generate a unique ID when not provided
          )
        end

        restaurant
      end

      def process_images(restaurant, images)
        images.each do |image|
          next unless image.content_type.start_with?("image/")
          restaurant.images.create!(file: image)
        end
      end

      def search_params
        params.permit(
          :search, :tag, :order_by, :order_direction, :latitude, :longitude, :per_page
        ).merge(user: current_user)
      end

      def restaurant_params
        params.require(:restaurant).permit(
          :name, :address, :city, :latitude, :longitude,
          :notes, :rating, :price_level, :google_place_id,
          :cuisine_type_name,
          tag_list: [],
          images: []
        )
      end

      def restaurant_update_params
        params.require(:restaurant).permit(
          :name, :address, :notes, :cuisine_type_id,
          :rating, :price_level, :street_number, :street,
          :postal_code, :city, :state, :country,
          :phone_number, :url, :business_status,
          :cuisine_type_name, :tag_list,
          images: []
        )
      end

      def render_collection(resources, meta: {}, pagy: nil)
        render json: RestaurantSerializer.render_collection(resources, meta: meta, pagy: pagy)
      end

      def render_success(resource, meta: {}, status: :ok)
        render json: RestaurantSerializer.render_success(resource, meta: meta), status: status
      end

      def render_error(errors, meta: {}, status: :unprocessable_entity)
        render json: RestaurantSerializer.render_error(errors, meta: meta), status: status
      end
    end
  end
end
