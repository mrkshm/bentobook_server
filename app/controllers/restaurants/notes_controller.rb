module Restaurants
  class NotesController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      if hotwire_native_app?
        render template: "restaurants/notes/edit_native"
      else
        render template: "restaurants/notes/edit"
      end
    end

    def update
      if @restaurant.update(notes_params)
        if hotwire_native_app?
          redirect_to restaurant_path(id: @restaurant.id, locale: nil)
        else
          render turbo_stream: turbo_stream.replace(
            dom_id(@restaurant, :notes),
            partial: "restaurants/notes/notes",
            locals: { restaurant: @restaurant }
          )
        end
      else
        if hotwire_native_app?
          render template: "restaurants/notes/edit_native",
                 status: :unprocessable_entity
        else
          render template: "restaurants/notes/edit",
                 status: :unprocessable_entity
        end
      end
    end

    private

    def set_restaurant
      @restaurant = current_user.restaurants.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant not found" }, status: :not_found
    end

    def notes_params
      params.require(:restaurant).permit(:notes)
    end
  end
end
