class RestaurantCardComponent < ViewComponent::Base
  include ImageHelper

  def initialize(restaurant:)
    @restaurant = restaurant
  end

  def thumbnail_url
    cover_image = @restaurant.images.find_by(is_cover: true) || @restaurant.images.first
    return nil unless cover_image

    # This will use our pre-generated variant
    image_variant_url(cover_image, :thumbnail)
  end
end
