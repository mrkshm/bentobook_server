module Api
  module V1
    class RestaurantsController < Api::V1::BaseController
      include Pagy::Backend
      include CuisineTypeValidation

      before_action :set_restaurant, only: [ :show, :update, :destroy, :add_tag, :remove_tag ]

      def index
        restaurants_scope = current_user.restaurants.with_google.includes(:visits, :cuisine_type, :tags)
        order_params = parse_order_params
        return if performed?

        query = RestaurantQuery.new(restaurants_scope, search_params.merge(order_params))
        @pagy, @restaurants = pagy(query.call, items: params.fetch(:per_page, 10))

        render_collection(
          @restaurants,
          pagy: @pagy,
          meta: {
            sorting: {
              field: order_params[:order_by] || RestaurantQuery::DEFAULT_ORDER[:field],
              direction: order_params[:order_direction] || RestaurantQuery::DEFAULT_ORDER[:direction]
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
            result = ImageProcessorService.new(restaurant, restaurant_params[:images]).process
            unless result.success?
              raise StandardError, result.error
            end
          end
        end

        render json: RestaurantSerializer.render_success(restaurant), status: :created
      rescue StandardError => e
        restaurant&.destroy if restaurant&.persisted?
        render_error(e.message)
      end

      def update
        ActiveRecord::Base.transaction do
          updater = RestaurantUpdater.new(@restaurant, restaurant_params.except(:images))

          if updater.update
            if restaurant_params[:images].present?
              result = ImageProcessorService.new(@restaurant, restaurant_params[:images]).process
              unless result.success?
                raise StandardError, result.error
              end
            end
            render_success(@restaurant)
          else
            render_error(@restaurant.errors.full_messages.join(", "), status: :unprocessable_entity)
          end
        end
      rescue StandardError => e
        render_error(e.message, status: :unprocessable_entity)
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

        # Validate and set cuisine type
        valid, result = validate_cuisine_type(restaurant_params[:cuisine_type_name])
        unless valid
          raise StandardError, result
        end
        restaurant.cuisine_type = result

        # Handle tags if present
        if restaurant_params[:tag_list].present?
          restaurant.tag_list = restaurant_params[:tag_list]
        end

        # Create or find google restaurant
        if restaurant_params[:google_place_id].present?
          google_restaurant = GoogleRestaurant.find_or_initialize_by_place_id(
            google_place_id: restaurant_params[:google_place_id],
            name: restaurant_params[:name],
            address: restaurant_params[:address],
            city: restaurant_params[:city],
            latitude: restaurant_params[:latitude]&.to_d,
            longitude: restaurant_params[:longitude]&.to_d,
            google_rating: restaurant_params[:rating],
            google_updated_at: Time.current
          )
          restaurant.google_restaurant = google_restaurant
        else
          restaurant.build_google_restaurant(
            name: restaurant_params[:name],
            address: restaurant_params[:address],
            city: restaurant_params[:city],
            latitude: restaurant_params[:latitude]&.to_d,
            longitude: restaurant_params[:longitude]&.to_d,
            google_rating: restaurant_params[:rating],
            google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}"  # Generate a unique ID when not provided
          )
        end

        restaurant
      end

      def search_params
        params.permit(
          :search, :tag, :latitude, :longitude, :per_page
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

      def parse_order_params
        return {} unless params[:order_by].present?

        unless RestaurantQuery::ALLOWED_ORDER_FIELDS.include?(params[:order_by])
          render_error("Invalid order_by parameter. Allowed values: #{RestaurantQuery::ALLOWED_ORDER_FIELDS.join(', ')}")
          return
        end

        unless [ "asc", "desc" ].include?(params[:order_direction]&.downcase)
          render_error("Invalid order_direction parameter. Allowed values: asc, desc")
          return
        end

        {
          order_by: params[:order_by],
          order_direction: params[:order_direction]&.downcase || "asc"
        }
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
