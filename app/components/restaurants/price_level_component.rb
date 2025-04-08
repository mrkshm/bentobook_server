# frozen_string_literal: true

module Restaurants
  class PriceLevelComponent < ApplicationComponent
    def initialize(restaurant:, readonly: false)
      @restaurant = restaurant
      @readonly = readonly
    end

    private

    attr_reader :restaurant, :readonly
  end
end
