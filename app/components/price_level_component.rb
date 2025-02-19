# frozen_string_literal: true

class PriceLevelComponent < ViewComponent::Base
  include RestaurantsHelper
  include HeroiconHelper

  def initialize(restaurant:, form: nil)
    @restaurant = restaurant
    @form = form
  end

  def call
    @form ? render_editable_price_level : render_readonly_price_level
  end

  private

  def render_readonly_price_level
    content_tag(:div, class: "flex items-center space-x-1") do
      (@restaurant.price_level || 0).times.map do
        heroicon("currency-dollar", options: { class: "w-5 h-5 text-green-600" })
      end.join.html_safe
    end
  end

  def render_editable_price_level
    @form.select :price_level, 
                 price_level_options, 
                 { include_blank: t("restaurants.select_price_level") }, 
                 class: "select select-bordered w-full max-w-xs"
  end
end
