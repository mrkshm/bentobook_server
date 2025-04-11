# frozen_string_literal: true

module Restaurants
  class PriceLevelComponent < ApplicationComponent
    include HeroiconHelper

    def initialize(restaurant:, readonly: false)
      @restaurant = restaurant
      @readonly = readonly
    end

    def frame_id
      "restaurant_#{restaurant.id}_price_level"
    end

    def hotwire_native_app?
      helpers.hotwire_native_app?
    rescue NoMethodError
      false
    end

    private

    attr_reader :restaurant, :readonly
  end
end
