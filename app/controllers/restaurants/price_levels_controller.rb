module Restaurants
  class PriceLevelsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      if hotwire_native_app?
        render template: "restaurants/price_levels/edit_native"
      else
        render turbo_stream: turbo_stream.replace(
          dom_id(@restaurant, :price_level),
          template: "restaurants/price_levels/edit"
        )
      end
    end

    def update
      if @restaurant.update(price_level_params)
        if hotwire_native_app?
          redirect_to restaurant_path(id: @restaurant.id, locale: current_locale)
        else
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :price_level),
            partial: "restaurants/price_levels/price_level",
            locals: { restaurant: @restaurant }
          )
        end
      else
        if hotwire_native_app?
          render template: "restaurants/price_levels/edit_native",
                 status: :unprocessable_entity
        else
          render template: "restaurants/price_levels/edit",
                 status: :unprocessable_entity
        end
      end
    end

    private

    def set_restaurant
      @restaurant = current_user.restaurants.find(params[:restaurant_id])
    end

    def price_level_params
      params.require(:restaurant).permit(:price_level)
    end
  end
end
