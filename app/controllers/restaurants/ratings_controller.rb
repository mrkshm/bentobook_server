module Restaurants
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      if hotwire_native_app?
        render template: "restaurants/ratings/edit_native"
      else
        render turbo_stream: turbo_stream.replace(
          dom_id(@restaurant, :rating),
          template: "restaurants/ratings/edit"
        )
      end
    end

    def update
      if @restaurant.update(rating_params)
        if hotwire_native_app?
          redirect_to restaurant_path(id: @restaurant.id, locale: nil)
        else
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :rating),
            partial: "restaurants/ratings/rating",
            locals: { restaurant: @restaurant }
          )
        end
      else
        if hotwire_native_app?
          render template: "restaurants/ratings/edit_native",
                 status: :unprocessable_entity
        else
          render template: "restaurants/ratings/edit",
                 status: :unprocessable_entity
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
  end
end
