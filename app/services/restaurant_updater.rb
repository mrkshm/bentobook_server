class RestaurantUpdater
  attr_reader :restaurant, :params

  def initialize(restaurant, params)
    @restaurant = restaurant
    @params = params
  end

  def update
    ActiveRecord::Base.transaction do
      # Store original values before any updates
      original_name = @restaurant.name
      original_address = @restaurant.address
      original_cuisine_type = @restaurant.cuisine_type
      original_tags = @restaurant.tag_list.to_a
      original_rating = @restaurant.rating
      original_price_level = @restaurant.price_level
      original_notes = @restaurant.notes
      
      update_basic_attributes
      update_cuisine_type
      update_tags
      
      # Check if anything changed by comparing with original values
      changed = @restaurant.name != original_name ||
                @restaurant.address != original_address ||
                @restaurant.cuisine_type != original_cuisine_type ||
                @restaurant.tag_list.to_a != original_tags ||
                @restaurant.rating != original_rating ||
                @restaurant.price_level != original_price_level ||
                @restaurant.notes != original_notes
      
      # Always save if attributes were assigned
      result = if changed
        @restaurant.save
      else
        true
      end

      
      result
    rescue => e
      Rails.logger.error "Update error: #{e.message}"
      @restaurant.errors.add(:base, e.message)
      false
    end
  end

  private

  def update_basic_attributes
    @restaurant.assign_attributes(
      @params.except(:cuisine_type_name, :images, :tag_list)
    )
  end

  def update_cuisine_type
    if @params[:cuisine_type_name].present?
      name = @params[:cuisine_type_name].downcase
      cuisine_type = CuisineType.find_by(name: name)
      
      if cuisine_type
        if @restaurant.cuisine_type != cuisine_type
          @restaurant.cuisine_type = cuisine_type
          @restaurant.save! # Save immediately to handle foreign key constraints
        end
      else
        raise ActiveRecord::RecordNotFound, "Cuisine type '#{name}' is not valid"
      end
    end
  end

  def update_tags
    @restaurant.tag_list = @params[:tag_list] if @params[:tag_list].present?
  end

  def update_images
    Array(@params[:images]).each do |image|
      next unless image.respond_to?(:content_type) && image.content_type.start_with?('image/')
      
      Rails.logger.info "Processing image: #{image.original_filename}"
      new_image = @restaurant.images.build(file: image)
      
      unless new_image.save
        Rails.logger.error "Failed to save image: #{new_image.errors.full_messages}"
        raise ActiveRecord::RecordInvalid.new(new_image)
      end
    end
  end
end
