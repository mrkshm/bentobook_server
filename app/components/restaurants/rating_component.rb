# frozen_string_literal: true

module Restaurants
  class RatingComponent < ApplicationComponent
    include ActionView::RecordIdentifier

    attr_reader :restaurant, :readonly

    def initialize(restaurant:, readonly: false)
      @restaurant = restaurant
      @readonly = readonly
    end

    def frame_id
      dom_id(restaurant, :rating)
    end
  end
end
