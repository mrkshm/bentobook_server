# frozen_string_literal: true

class PriceLevelComponent < ViewComponent::Base
    def initialize(restaurant:, form: nil)
      @restaurant = restaurant
      @form = form
    end
  
    def call
      if @form
        render_editable_price_level
      else
        render_readonly_price_level
      end
    end
  
    private
  
    def render_readonly_price_level
      content_tag(:span, @restaurant.price_level_display, class: "font-bold text-green-600")
    end
  
    def render_editable_price_level
      @form.select :price_level, 
                   price_level_options, 
                   { include_blank: "Select price level" }, 
                   class: "select select-bordered w-full max-w-xs"
    end
  
    def price_level_options
      [
        ['$', 1],
        ['$$', 2],
        ['$$$', 3],
        ['$$$$', 4]
      ]
    end
  end