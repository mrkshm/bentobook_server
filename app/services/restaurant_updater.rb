class RestaurantUpdater
  attr_reader :restaurant, :params

  def initialize(restaurant, params)
    @restaurant = restaurant
    @params = params
  end

  def update
    Rails.logger.info "Starting update for restaurant #{restaurant.id}"
    changes_made = false
    changes_made |= update_comparable_attributes
    changes_made |= update_cuisine_type
    changes_made |= update_non_comparable_attributes
    changes_made |= update_images

    Rails.logger.info "Changes made: #{changes_made}"

    if changes_made
      if restaurant.save
        Rails.logger.info "Restaurant #{restaurant.id} updated successfully"
        true
      else
        Rails.logger.error "Failed to save restaurant #{restaurant.id}: #{restaurant.errors.full_messages}"
        false
      end
    else
      Rails.logger.info "No changes detected for restaurant #{restaurant.id}"
      false
    end
  end

  private

  def update_comparable_attributes
    changes_made = false
    (RestaurantManagement::COMPARABLE_ATTRIBUTES + [:name]).each do |attr|
      new_value = params[attr.to_s] || params[attr]
      current_value = restaurant.send(attr)

      if new_value.present? && new_value.to_s != current_value.to_s
        restaurant.send("#{attr}=", new_value)
        changes_made = true
      end
    end
    changes_made
  end

  def update_cuisine_type
    if params[:cuisine_type_name].present?
      cuisine_type_name = params[:cuisine_type_name].downcase
      cuisine_type = nil
      CuisineType.transaction do
        cuisine_type = CuisineType.find_or_create_by!(name: cuisine_type_name)
      end
      if restaurant.cuisine_type != cuisine_type
        restaurant.cuisine_type = cuisine_type
        restaurant.save!  # Save the restaurant to persist the cuisine_type change
        true
      else
        false
      end
    elsif params[:cuisine_type_id].present?
      new_cuisine_type = CuisineType.find_by(id: params[:cuisine_type_id])
      if restaurant.cuisine_type != new_cuisine_type
        restaurant.cuisine_type = new_cuisine_type
        restaurant.save!  # Save the restaurant to persist the cuisine_type change
        true
      else
        false
      end
    else
      false
    end
  end

  def update_non_comparable_attributes
    changes_made = false
    [:rating, :notes, :cuisine_type_id, :tag_list, :price_level].each do |attr|
      if params[attr].present? && params[attr] != restaurant.send(attr)
        restaurant.send("#{attr}=", params[attr])
        changes_made = true
      end
    end
    changes_made
  end

  def update_images
    if params[:images].present?
      params[:images].each do |image|
        restaurant.images.build(file: image) if image.respond_to?(:tempfile)
      end
      restaurant.save  # Save the restaurant to persist the images
      true
    else
      false
    end
  end
end
