module Restaurants
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      render template: "restaurants/ratings/edit"
    end

    def update
      if @restaurant.update(rating_params)
        if hotwire_native_app?
          redirect_to restaurant_path(id: @restaurant.id, locale: current_locale)
        else
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :rating),
            Restaurants::RatingComponent.new(restaurant: @restaurant).render_in(view_context)
          )
        end
      else
        render template: "restaurants/ratings/edit",
               status: :unprocessable_entity
      end
    end

    private

    def set_restaurant
      @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant not found" }, status: :not_found
      false # Return false to halt the filter chain
    end

    def rating_params
      params.require(:restaurant).permit(:rating)
    end
  end
end
