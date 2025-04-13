module Restaurants
  class RatingsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      render template: "restaurants/ratings/edit"
    end

    def update
      @restaurant = Current.organization.restaurants.find(params[:restaurant_id])

      if @restaurant.update(rating_params)
        # Force cache control headers to prevent stale data
        response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"

        if hotwire_native_app?
          # Add timestamp to URL to bust cache
          timestamp = Time.current.to_i
          redirect_url = restaurant_path(id: @restaurant.id, locale: current_locale, t: timestamp)

          redirect_to redirect_url,
            data: { turbo_action: "replace", turbo_frame: "_top" }
        else
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :rating),
            partial: "restaurants/ratings/display", locals: { restaurant: @restaurant.reload }
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
