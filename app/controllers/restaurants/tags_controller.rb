module Restaurants
  class TagsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_restaurant

    def edit
      @available_tags = current_user.restaurants.tag_counts_on(:tags).map(&:name)

      if hotwire_native_app?
        render :edit_native
      else
        render :edit
      end
    end

    def update
      @available_tags = current_user.restaurants.tag_counts_on(:tags).map(&:name)
      result = Restaurants::Tags::ManagerService.new(@restaurant).update(params[:restaurant][:tags])

      if result.success?
        respond_to do |format|
          format.html do
            flash[:notice] = t("tags.successfully_updated")
            redirect_to restaurant_path(id: @restaurant.id, locale: nil)
          end
          format.turbo_stream do
            flash.now[:notice] = t("tags.successfully_updated")
            render turbo_stream: turbo_stream.replace(
              dom_id(@restaurant, :tags),
              partial: "restaurants/tags/tags",
              locals: { restaurant: @restaurant }
            )
          end
        end
      else
        handle_failed_update(result.error)
      end
    rescue JSON::ParserError
      handle_failed_update("Invalid tag format")
    end

    def add
      result = Restaurants::Tags::ManagerService.new(@restaurant).add(tag_params[:tag])

      if result.success?
        redirect_to restaurant_path(@restaurant), notice: "Tag added successfully."
      else
        flash[:alert] = result.error
        render :show
      end
    end

    def remove
      result = Restaurants::Tags::ManagerService.new(@restaurant).remove(tag_params[:tag])

      if result.success?
        redirect_to restaurant_path(@restaurant), notice: "Tag removed successfully."
      else
        flash[:alert] = result.error
        render :show
      end
    end

    private

    def set_restaurant
      @restaurant = current_user.restaurants.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant not found" }, status: :not_found
    end

    def tag_params
      params.permit(:tag)
    end

    def handle_successful_update
      if hotwire_native_app?
        redirect_to restaurant_path(id: @restaurant.id, locale: nil),
                    notice: t("tags.successfully_updated")
      else
        respond_to do |format|
          format.html do
            redirect_to restaurant_path(id: @restaurant.id, locale: nil),
                        notice: t("tags.successfully_updated")
          end
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              dom_id(@restaurant, :tags),
              partial: "restaurants/tags/tags",
              locals: { restaurant: @restaurant }
            )
          end
          format.json { render json: { status: :ok } }
        end
      end
    end

    def handle_failed_update(error_message)
      respond_to do |format|
        format.html do
          flash.now[:alert] = error_message
          render_error_response
        end
        format.json { render json: { error: error_message }, status: :unprocessable_entity }
      end
    end

    def render_error_response
      if hotwire_native_app?
        render :edit_native, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
