module Api
  module V1
    class RestaurantsController < Api::V1::BaseController
      include RestaurantManagement
      include Api::V1::RestaurantSortingAndFiltering
      include Pagy::Backend
      before_action :set_restaurant, only: [:show, :update, :destroy, :add_tag, :remove_tag]

      def index
        order_field, order_direction, using_default, message = parse_order_params
        return if performed?

        restaurants_scope = current_user.restaurants.with_google.includes(:visits)

        restaurants_scope = apply_filters(restaurants_scope)
        restaurants_scope = apply_ordering(restaurants_scope, order_field, order_direction)

        @pagy, @restaurants = pagy(restaurants_scope, items: 10)

        user_location = params[:latitude] && params[:longitude] ? [params[:latitude].to_f, params[:longitude].to_f] : nil

        response_data = {
          restaurants: @restaurants.map { |restaurant| 
            RestaurantSerializer.new(restaurant, params: { user_location: user_location }).to_h
          },
          pagy: pagy_metadata(@pagy),
          sorting: { field: order_field, direction: order_direction }
        }

        response_data[:message] = message if message

        render json: response_data
      end

      def show
        restaurant_data = RestaurantSerializer.new(@restaurant).to_h
        visits_data = @restaurant.visits.map { |visit| VisitSerializer.new(visit).to_h }
        render json: restaurant_data.merge(visits: visits_data), status: :ok
      end

      def destroy
        @restaurant.destroy!
        render json: { message: 'Restaurant was successfully removed from your list.' }, status: :ok
      end

      def create
        puts "Incoming parameters: #{params.inspect}"
        ActiveRecord::Base.transaction do
          # Exclude :cuisine_type and :google_place_id from restaurant_params
          restaurant_attributes = restaurant_params.except(:cuisine_type, :google_place_id)
          @restaurant = current_user.restaurants.new(restaurant_attributes)
          
          @restaurant.cuisine_type = CuisineType.find_or_create_by(name: params[:restaurant][:cuisine_type])
          
          @google_restaurant = find_or_create_google_restaurant
          puts "Google Restaurant after find_or_create: #{@google_restaurant.inspect}"

          @restaurant.google_restaurant = @google_restaurant

          if @restaurant.save
            render json: RestaurantSerializer.new(@restaurant).serialize, status: :created
          else
            puts "Restaurant save failed: #{@restaurant.errors.full_messages}"
            render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        puts "Record Invalid: #{e.message}"
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      def update
        updater = RestaurantUpdater.new(@restaurant, restaurant_update_params)
        updater.update!
        render json: RestaurantSerializer.new(@restaurant).serialize, status: :ok
      end

      def add_tag
        tag_name = params[:tag]
        @restaurant.tag_list.add(tag_name) unless @restaurant.tag_list.include?(tag_name)
        @restaurant.save!
        render json: { message: 'Tag added successfully.', tags: @restaurant.tag_list }, status: :ok
      end

      def remove_tag
        tag_name = params[:tag]
        @restaurant.tag_list.remove(tag_name)
        @restaurant.save!
        render json: { message: 'Tag removed successfully.', tags: @restaurant.tag_list }, status: :ok
      end

      def tagged
        tag_name = params[:tag]
        restaurants_scope = current_user.restaurants.tagged_with(tag_name)

        items_per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10

        @pagy, restaurants = pagy(restaurants_scope, items: items_per_page)

        render json: {
          restaurants: RestaurantSerializer.new(restaurants).serializable_hash,
          pagination: pagy_metadata(@pagy)
        }, status: :ok
      rescue Pagy::OverflowError
        render json: {
          restaurants: [],
          pagination: pagy_metadata(Pagy.new(count: 0, page: 1))
        }, status: :ok
      end

      private

      def create_images
        return unless restaurant_params[:images].present?

        restaurant_params[:images].each do |image|
          @restaurant.images.create(file: image)
        end
      end

      def restaurant_params
        params.require(:restaurant).permit(
          :name, :address, :city, :latitude, :longitude, :notes, :rating, :price_level, :google_place_id, :cuisine_type
        )
      end
    end
  end
end
