# frozen_string_literal: true

module Restaurants
  class RatingComponent < ApplicationComponent
    include HeroiconHelper

    def initialize(restaurant:, readonly: false)
      @restaurant = restaurant
      @readonly = readonly
    end

    def frame_id
      helpers.dom_id(restaurant, :rating)
    end

    def readonly?
      @readonly
    end

    private

    attr_reader :restaurant, :readonly
  end
end
