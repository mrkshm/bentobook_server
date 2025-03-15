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
        respond_to do |format|
          format.html { redirect_to restaurant_path(id: @restaurant.id, locale: nil) }
          format.turbo_stream {
            render turbo_stream: [
              turbo_stream.replace(
                dom_id(@restaurant, :rating),
                partial: "restaurants/ratings/rating",
                locals: {
                  restaurant: @restaurant,
                  rating_stars: rating_component.rating_stars
                }
              ),
              turbo_stream.update("modal", "")  # This clears the modal
            ]
          }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_restaurant
      @restaurant = current_user.restaurants.find(params[:restaurant_id])
    end

    def rating_params
      params.require(:restaurant).permit(:rating)
    end

    def rating_component
      @rating_component ||= RatingComponent.new(restaurant: @restaurant)
    end
  end
end
