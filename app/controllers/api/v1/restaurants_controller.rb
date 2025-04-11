module Api
  module V1
    class RestaurantsController < Api::V1::BaseController
      include Pagy::Backend
      include CuisineTypeValidation

      before_action :set_restaurant, only: [ :show, :update, :destroy, :add_tag, :remove_tag ]

      def index
        restaurants_scope = Current.organization.restaurants.with_google.includes(:visits, :cuisine_type, :tags)
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
        # Log the tag_list parameter for debugging
        Rails.logger.debug "Tag list param: #{params.dig(:restaurant, :tag_list).inspect}"
        Rails.logger.debug "Restaurant params: #{restaurant_params.inspect}"
        
        restaurant = Current.organization.restaurants.new(restaurant_params.except(:cuisine_type_name))
        Rails.logger.debug "Restaurant tag_list after init: #{restaurant.tag_list.inspect}"

        # First check if the restaurant is valid (name, etc.)
        unless restaurant.valid?
          return render_error(restaurant.errors.full_messages.join(", "), :unprocessable_entity)
        end

        # Then handle cuisine_type_name if provided
        if restaurant_params[:cuisine_type_name].present?
          valid, result = validate_cuisine_type(restaurant_params[:cuisine_type_name])
          unless valid
            return render_error(result, :unprocessable_entity)
          end
          restaurant.cuisine_type = result
        else
          return render_error("Cuisine type is required", :unprocessable_entity)
        end

        # Add location data directly to the restaurant if provided
        if location_params.present?
          restaurant.assign_attributes(
            address: location_params[:address],
            city: location_params[:city],
            street: location_params[:street],
            street_number: location_params[:street_number],
            postal_code: location_params[:postal_code],
            country: location_params[:country],
            latitude: location_params[:latitude],
            longitude: location_params[:longitude]
          )
        end

        # Optionally associate with Google restaurant if place ID is provided
        if params[:google_place_id].present?
          google_restaurant = GoogleRestaurant.find_by(google_place_id: params[:google_place_id])
          restaurant.google_restaurant = google_restaurant if google_restaurant
          
          # If we have a Google restaurant but no location data in the restaurant itself,
          # copy the location data from the Google restaurant
          if google_restaurant && (!restaurant.latitude || !restaurant.longitude)
            restaurant.latitude = google_restaurant.latitude
            restaurant.longitude = google_restaurant.longitude
          end
        end

        if restaurant.save
          if restaurant_params[:images].present?
            result = ImageProcessorService.new(restaurant, restaurant_params[:images]).process
            unless result.success?
              restaurant.destroy
              return render_error(result.error)
            end
          end
          render json: RestaurantSerializer.render_success(restaurant), status: :created
        else
          render_error(restaurant.errors.full_messages.join(", "), :unprocessable_entity)
        end
      rescue ActionController::ParameterMissing => e
        render_error(e.message, :unprocessable_entity)
      rescue StandardError => e
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
            render_error(@restaurant.errors.full_messages.join(", "), :unprocessable_entity)
          end
        end
      rescue StandardError => e
        render_error(e.message, :unprocessable_entity)
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
        unless @restaurant
          # This is a fallback in case set_restaurant didn't properly halt the chain
          return render_error("Restaurant not found", :not_found)
        end
        
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
        unless @restaurant
          # This is a fallback in case set_restaurant didn't properly halt the chain
          return render_error("Restaurant not found", :not_found)
        end
        
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
        Rails.logger.debug "=== DEBUG: set_restaurant called for #{params[:controller]}##{params[:action]} with ID: #{params[:id]} ==="
        @restaurant = Current.organization.restaurants.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.debug "=== DEBUG: Restaurant not found: #{e.message} ==="
        render_error("Restaurant not found", :not_found)
        false # Return false to halt the filter chain
      end

      def search_params
        params.permit(
          :search, :tag, :latitude, :longitude, :per_page
        ).merge(organization: Current.organization)
      end

      def restaurant_params
        params.require(:restaurant).permit(
          :name, :notes, :rating, :price_level,
          :cuisine_type_name, :favorite,
          :address, :city, :street, :street_number,
          :postal_code, :country, :phone_number, :url,
          tag_list: [],
          images: []
        )
      end

      def location_params
        return nil unless params[:location].present?

        params.require(:location).permit(
          :address,
          :city,
          :street,
          :postal_code,
          :country,
          :latitude,
          :longitude
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

      def render_error(message, status = :unprocessable_entity, pointer = nil)
        render json: BaseSerializer.render_error(message, status, pointer), status: status
      end
    end
  end
end
