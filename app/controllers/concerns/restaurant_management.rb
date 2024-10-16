module RestaurantManagement
    extend ActiveSupport::Concern
    
    COMPARABLE_ATTRIBUTES = [
      :name, :address, :street_number, :street, :postal_code, :city, :state, :country,
      :phone_number, :url, :business_status, :latitude, :longitude
    ].freeze
  
    def set_restaurant
      @restaurant = current_user.restaurants.with_google.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      if request.format.json?
        render json: { error: "Restaurant not found or you don't have permission to view it" }, status: :not_found
      else
        flash[:alert] = "Restaurant not found or you don't have permission to view it."
        redirect_to restaurants_path
      end
    end
  
    def build_restaurant
      @restaurant = current_user.restaurants.new(restaurant_params.except(:images))
      
      if restaurant_params[:images].present?
        restaurant_params[:images].each do |image|
          @restaurant.images.new(file: image)
        end
      end

      @restaurant
    end
  
    def compare_and_save_restaurant
      restaurant_attrs = restaurant_params
      google_restaurant = @restaurant.google_restaurant

      @restaurant.name = restaurant_attrs[:name].presence || google_restaurant&.name || @restaurant.name
      @restaurant.address = restaurant_attrs[:address].presence || google_restaurant&.address || @restaurant.address
      @restaurant.rating = restaurant_attrs[:rating] if restaurant_attrs[:rating].present?
      @restaurant.price_level = restaurant_attrs[:price_level] if restaurant_attrs[:price_level].present?
      @restaurant.notes = restaurant_attrs[:notes] if restaurant_attrs[:notes].present?
      @restaurant.cuisine_type_id = restaurant_attrs[:cuisine_type_id] if restaurant_attrs[:cuisine_type_id].present?

      @restaurant.save
    end
  
    private
  
    def google_restaurant_params
      params.dig(:restaurant, :google_restaurant_attributes)&.permit(
        :id, :google_place_id, :name, :address, :city, :state, :country,
        :latitude, :longitude, :street_number, :street, :postal_code,
        :phone_number, :url, :business_status, :price_level
      ) || {}
    end
  
    def restaurant_params
      params.require(:restaurant).permit(
        :name, :address, :notes, :cuisine_type, :rating, :price_level,
        :google_place_id, :city, :latitude, :longitude,
        images: []
      )
    end
  
    def restaurant_save_params
      params.require(:restaurant).permit(
        :name, :address, :notes, :cuisine_type_id, :rating, :price_level,
        google_restaurant_attributes: google_restaurant_params.keys,
        images: []
      )
    end
  
    def restaurant_update_params
      params.require(:restaurant).permit(
        :name, :address, :notes, :cuisine_type_id, :rating, :price_level,
        :street_number, :street, :postal_code, :city, :state, :country,
        :phone_number, :url, :business_status, :tag_list,
        :cuisine_type_name,
        images: []
      )
    end
  
    def find_or_create_google_restaurant
      google_attrs = google_restaurant_params
      Rails.logger.debug "Google attrs: #{google_attrs.inspect}"
      return nil if google_attrs.blank?

      google_place_id = google_attrs[:google_place_id]
      Rails.logger.debug "Google place ID: #{google_place_id}"
      return nil if google_place_id.blank?

      # Check if latitude and longitude are present
      if google_attrs[:latitude].blank? || google_attrs[:longitude].blank?
        Rails.logger.error "Latitude or longitude is missing"
        return nil
      end

      google_restaurant = GoogleRestaurant.find_or_create_by(google_place_id: google_place_id) do |gr|
        Rails.logger.debug "Creating new GoogleRestaurant"
        gr.assign_attributes(google_attrs)
      end
      
      if google_restaurant.persisted?
        Rails.logger.debug "Updating existing GoogleRestaurant"
        google_restaurant.update(google_attrs)
      else
        Rails.logger.debug "Failed to create GoogleRestaurant"
      end

      unless google_restaurant.valid?
        Rails.logger.error "GoogleRestaurant is invalid: #{google_restaurant.errors.full_messages}"
      end

      Rails.logger.debug "GoogleRestaurant after find_or_create_by: #{google_restaurant.inspect}"
      Rails.logger.debug "GoogleRestaurant persisted?: #{google_restaurant.persisted?}"
      Rails.logger.debug "GoogleRestaurant errors: #{google_restaurant.errors.full_messages}"

      google_restaurant
    end
  
  end
