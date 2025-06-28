module Restaurants
  class CuisineSelectionsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :set_restaurant
    before_action :load_categories, only: [ :index, :edit, :cuisine_types ]
    before_action :authenticate_user!

    def index
    end

    def edit
      @categories = CuisineCategory.ordered
      @selected_category = if params[:category_id].present?
        # Find the category by ID and ensure it exists
        category = CuisineCategory.find_by(id: params[:category_id])
        # If category not found, use the restaurant's cuisine type's category
        category || @restaurant.cuisine_type&.cuisine_category || @categories.first
      else
        @restaurant.cuisine_type&.cuisine_category || @categories.first
      end
      @cuisine_types = @selected_category&.cuisine_types&.alphabetical || []
      render template: "restaurants/cuisine_selections/edit"
    end

    def update
      if @restaurant.update(cuisine_type_id: params[:cuisine_type_id])
        respond_to do |format|
          format.html do
            redirect_to restaurant_path(id: @restaurant.id, locale: current_locale)
          end
          format.turbo_stream do
            if hotwire_native_app?
              # For Hotwire Native, we'll use a custom template to break out of the frame
              render template: "restaurants/cuisine_selections/update"
            else
              # For web, we'll continue to replace the partial
              render turbo_stream: turbo_stream.replace(
                dom_id(@restaurant, :cuisine_type),
                partial: "restaurants/cuisine_selections/display",
                locals: { restaurant: @restaurant }
              )
            end
          end
        end
      else
        render template: "restaurants/cuisine_selections/edit", status: :unprocessable_entity
      end
    end

    def cuisine_types
      @category = CuisineCategory.find(params[:id])
      @cuisine_types = @category.cuisine_types.alphabetical
      render partial: "cuisine_types"
    end

    def update_cuisine_type
      @restaurant.update!(cuisine_type_id: params[:cuisine_type_id])
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @restaurant, notice: "Cuisine type updated" }
      end
    end

    private

    def set_restaurant
      @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant not found" }, status: :not_found
    end

    def load_categories
      @categories = CuisineCategory.ordered
    end
  end
end
