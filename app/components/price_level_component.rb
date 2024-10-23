# frozen_string_literal: true

class PriceLevelComponent < ViewComponent::Base
  include RestaurantsHelper

  def initialize(restaurant:, form: nil)
    @restaurant = restaurant
    @form = form
  end

  def call
    render(@form ? :render_editable_price_level : :render_readonly_price_level)
  end

  private

  def render_readonly_price_level
    content_tag(:span, @restaurant.price_level_display, class: "font-bold text-green-600")
  end

  def render_editable_price_level
    @form.select :price_level, 
                 price_level_options, 
                 { include_blank: t("restaurants.select_price_level") }, 
                 class: "select select-bordered w-full max-w-xs"
  end
end