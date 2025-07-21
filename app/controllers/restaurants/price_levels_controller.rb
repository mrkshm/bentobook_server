module Restaurants
  class PriceLevelsController < ApplicationController
    include ActionView::RecordIdentifier
    include RestaurantScoped

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      respond_to do |format|
        format.html { render template: "restaurants/price_levels/edit" }
        format.turbo_stream # renders app/views/restaurants/price_levels/edit.turbo_stream.erb
      end
    end

    def update
      if @restaurant.update(price_level_params)
        respond_to do |format|
          format.html do
            redirect_to restaurant_path(id: @restaurant.id)
          end
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream { render :edit, status: :unprocessable_entity }
        end
      end
    end

    private

    def price_level_params
      params.require(:restaurant).permit(:price_level)
    end
  end
end
