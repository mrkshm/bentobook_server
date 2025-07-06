# frozen_string_literal: true

# Handles updating a restaurant's business status
class Restaurants::BusinessStatusController < ApplicationController
  before_action :set_restaurant
  before_action :authenticate_user!
  before_action :validate_business_status, only: :update

  # GET /restaurants/:restaurant_id/business_status/edit
  def edit
    respond_to do |format|
      format.html { render layout: !hotwire_native_app? }
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/business_status
  def update
    if @restaurant.update(business_status: params[:business_status])
      handle_successful_update
    else
      handle_failed_update
    end
  end

  private

  def set_restaurant
    @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
  end

  def validate_business_status
    return if Restaurant::BUSINESS_STATUS.value?(params[:business_status])
    
    flash[:alert] = "Invalid business status"
    redirect_to edit_restaurant_business_status_path(@restaurant)
  end

  def handle_successful_update
    respond_to do |format|
      format.html do
        redirect_to @restaurant,
                    status: :see_other,
                    notice: "Business status updated successfully"
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.action(
          "visit",
          restaurant_path(@restaurant),
          "data-turbo-action": "replace"
        )
      end
    end
  end

  def handle_failed_update
    respond_to do |format|
      format.html do
        flash.now[:alert] = @restaurant.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
      format.turbo_stream do
        render :edit, status: :unprocessable_entity
      end
    end
  end
end