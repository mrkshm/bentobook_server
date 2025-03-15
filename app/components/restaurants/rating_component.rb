module Restaurants
  class RatingComponent < ViewComponent::Base
    include ActionView::RecordIdentifier
    include Turbo::FramesHelper

    attr_reader :restaurant

    def initialize(restaurant:)
      @restaurant = restaurant
    end

    def rating_stars
      5.times.map do |i|
        {
          filled: i < restaurant.rating.to_i,
          value: i + 1
        }
      end
    end

    def edit_path
      edit_restaurant_rating_path(restaurant_id: restaurant.id, locale: nil)
    end
  end
end
