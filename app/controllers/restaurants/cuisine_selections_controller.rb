module Restaurants
  class CuisineSelectionsController < ApplicationController
    before_action :set_restaurant, only: [ :update_cuisine_type ]
    before_action :load_categories, only: [ :index, :cuisine_types ]
    before_action :authenticate_user!

    def index
    end

    def edit
      @categories = CuisineCategory.ordered
      @selected_category = if params[:category_id]
                            CuisineCategory.find(params[:category_id])
      else
                            @restaurant.cuisine_type&.cuisine_category
      end
      @cuisine_types = @selected_category&.cuisine_types&.ordered || []
    end

    def update
      if @restaurant.update(cuisine_type_id: params[:cuisine_type_id])
        if hotwire_native_app?
          redirect_to restaurant_path(@restaurant)
        else
          render partial: "restaurants/cuisine_selections/display", locals: { restaurant: @restaurant }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def cuisine_types
      @category = CuisineCategory.find(params[:id])
      @cuisine_types = @category.cuisine_types.ordered
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
