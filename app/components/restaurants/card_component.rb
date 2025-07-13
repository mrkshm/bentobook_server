# frozen_string_literal: true

module Restaurants
  class CardComponent < ApplicationComponent
    def initialize(restaurant:)
      @restaurant = restaurant
    end

    # Add helper method for view context access
    def hotwire_native_app?
      view_context.respond_to?(:hotwire_native_app?) && view_context.hotwire_native_app?
    end

    private

    attr_reader :restaurant

    def formatted_address
      [
        "#{restaurant.street_number} #{restaurant.street}",
        [ restaurant.postal_code, restaurant.city ].compact.join(" "),
        restaurant.state,
        restaurant.country
      ].compact.reject(&:empty?).join(", ")
    end

    def visit_count
      restaurant.visit_count
    end
  end
end
