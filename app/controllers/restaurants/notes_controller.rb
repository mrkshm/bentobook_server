module Restaurants
  class NotesController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      render template: "restaurants/notes/edit"
    end

    def update
      if @restaurant.update(notes_params)
          if hotwire_native_app?
            redirect_to restaurant_path(id: @restaurant.id, locale: current_locale)
          else
            render turbo_stream: turbo_stream.replace(
              dom_id(@restaurant, :notes),
              partial: "restaurants/notes/notes",
              locals: { restaurant: @restaurant }
            )
          end
      else
          render template: "restaurants/notes/edit",
                 status: :unprocessable_entity
      end
    end

    private

    def set_restaurant
      @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant not found" }, status: :not_found
    end

    def notes_params
      params.require(:restaurant).permit(:notes)
    end
  end
end
