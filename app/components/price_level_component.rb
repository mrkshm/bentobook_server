# frozen_string_literal: true

class PriceLevelComponent < ViewComponent::Base
  include RestaurantsHelper
  include HeroiconHelper
  include ActionView::RecordIdentifier

  def initialize(price_level: nil, form: nil, readonly: false, size: :md, dom_id: nil, restaurant: nil)
    @price_level = price_level.to_i  # Match ratings pattern
    @form = form
    @readonly = readonly
    @size = size
    @dom_id = dom_id || (restaurant ? dom_id(restaurant, :price_level) : nil)
    @restaurant = restaurant
  end

  def call
    if @readonly
      render_readonly_price_level
    else
      render_editable_price_level
    end
  end

  private

  def render_readonly_price_level
    content_tag(:div, class: "flex items-center space-x-1", id: @dom_id) do
      (@price_level || 0).times.map do
        heroicon("currency-dollar", options: { class: "w-5 h-5 text-green-600" })
      end.join.html_safe
    end
  end

  def render_editable_price_level
    content_for :modals do
      render partial: "restaurants/price_level_modal", locals: { restaurant: @restaurant }
    end

    # Render the price level display button
    tag.div(class: "flex items-center",
            id: @dom_id,
            data: {
              controller: "price-level",
              price_level_url_value: restaurant_path(@restaurant),
              price_level_level_value: @price_level
            }) do
      content_tag(:button,
                 type: "button",
                 class: "flex items-center space-x-1 cursor-pointer focus:outline-none",
                 data: { action: "click->price-level#openModal" }) do
        (@price_level || 0).times.map do
          heroicon("currency-dollar", options: { class: "w-5 h-5 text-green-600" })
        end.join.html_safe
      end
    end
  end
end
