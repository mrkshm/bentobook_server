module Restaurants
  class RatingComponent < ViewComponent::Base
    include ActionView::RecordIdentifier

    def initialize(restaurant:)
      @restaurant = restaurant
    end

    def rating_stars
      stars = []
      5.times do |i|
        stars << {
          filled: i < @restaurant.rating.to_i,
          value: i + 1
        }
      end
      stars
    end

    def edit_path
      edit_restaurant_rating_path(restaurant_id: @restaurant.id, locale: nil)
    end

    private

    attr_reader :restaurant
  end
end
