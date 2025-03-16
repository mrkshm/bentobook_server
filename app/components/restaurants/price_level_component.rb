module Restaurants
  class PriceLevelComponent < ViewComponent::Base
    include ActionView::RecordIdentifier

    attr_reader :restaurant

    def initialize(restaurant:)
      @restaurant = restaurant
    end

    def frame_id
      dom_id(restaurant, :price_level)
    end
  end
end
