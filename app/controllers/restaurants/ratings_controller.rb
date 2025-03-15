module Restaurants
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      render hotwire_native_app? ? :edit_native : :edit
    end

    def update
      if @restaurant.update(rating_params)
        if hotwire_native_app?
          redirect_to restaurant_path(id: @restaurant.id, locale: nil)
        else
          render turbo_stream: [
            turbo_stream.replace(
              dom_id(@restaurant, :rating),
              partial: "restaurants/ratings/rating",
              locals: {
                restaurant: @restaurant,
                rating_stars: rating_stars(@restaurant)
              }
            ),
            turbo_stream.update("modal", "")
          ]
        end
      else
        if hotwire_native_app?
          render :edit_native, status: :unprocessable_entity
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end

    private

    def set_restaurant
      @restaurant = current_user.restaurants.find(params[:restaurant_id])
    end

    def rating_params
      params.require(:restaurant).permit(:rating)
    end

    def rating_stars(restaurant)
      5.times.map do |i|
        {
          filled: i < restaurant.rating.to_i,
          value: i + 1
        }
      end
    end
  end
end
