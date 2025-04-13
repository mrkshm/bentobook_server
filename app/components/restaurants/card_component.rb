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
        "#{restaurant.combined_street_number} #{restaurant.combined_street}",
        [ restaurant.combined_postal_code, restaurant.combined_city ].compact.join(" "),
        restaurant.combined_state,
        restaurant.combined_country
      ].compact.reject(&:empty?).join(", ")
    end

    def visit_count
      restaurant.visit_count
    end
  end
end
