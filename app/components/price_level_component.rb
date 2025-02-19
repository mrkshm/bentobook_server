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
    # Render modal content at page level
    content_for :modals do
      tag.div(id: "#{@dom_id}_modal_container") do
        render(ModalComponent.new(id: "#{@dom_id}_modal")) do |modal|
          modal.with_header { tag.h3("Set price level", class: "text-lg font-medium text-surface-900") }

          modal.with_body do
            tag.div(class: "flex items-center justify-center gap-4 py-4",
                   data: {
                     controller: "price-level",
                     price_level_url_value: restaurant_path(),
                     price_level_level_value: @price_level
                   }) do
              (1..4).map do |i|
                button_tag(type: "button",
                          class: "w-12 h-12 focus:outline-none transition-transform hover:scale-110",
                          data: {
                            price_level_target: "dollar",
                            value: i,
                            action: "click->price-level#setLevel"
                          }) do
                  heroicon("currency-dollar",
                          options: { class: "w-8 h-8 #{i <= @price_level ? 'text-green-600' : 'text-gray-400'}" })
                end
              end.join.html_safe
            end
          end
        end
      end
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
