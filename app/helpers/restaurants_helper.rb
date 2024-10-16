module RestaurantsHelper
    def sort_direction(field)
      if params[:order_by] == field && params[:order_direction] == 'asc'
        'desc'
      else
        'asc'
      end
    end

    def restaurant_attribute(restaurant, attribute)
      case attribute
      when :cuisine_type
        restaurant.cuisine_type&.name
      when :tags
        restaurant.tags.pluck(:name)
      else
        restaurant.send("combined_#{attribute}")
      end
    end
end
