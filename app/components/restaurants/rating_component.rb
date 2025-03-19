module Restaurants
  class RatingComponent < ApplicationComponent
    include ActionView::RecordIdentifier

    attr_reader :restaurant

    def initialize(restaurant:)
      @restaurant = restaurant
    end

    def frame_id
      dom_id(restaurant, :rating)
    end
  end
end
