# frozen_string_literal: true

class RestaurantCardComponent < ApplicationComponent
    def initialize(restaurant:)
      @restaurant = restaurant
    end
  
    private
  
    attr_reader :restaurant
  
    def formatted_address
      [
        "#{restaurant.street_number} #{restaurant.street}",
        [restaurant.postal_code, restaurant.city].compact.join(' '),
        restaurant.state,
        restaurant.country
      ].compact.reject(&:empty?).join(', ')
    end
  end
  