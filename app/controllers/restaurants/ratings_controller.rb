module Restaurants
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier
    include RestaurantScoped

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      respond_to do |format|
        format.html { render template: "restaurants/ratings/edit" }
        format.turbo_stream # renders app/views/restaurants/ratings/edit.turbo_stream.erb
      end
    end

    def update
      if @restaurant.update(rating_params)
        respond_to do |format|
          format.html do
            redirect_to restaurant_path(id: @restaurant.id)
          end
          format.turbo_stream # renders update.turbo_stream.erb
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream { render :edit, status: :unprocessable_entity }
        end
      end
    end

    private

    def rating_params
      params.require(:restaurant).permit(:rating)
    end
  end
end
