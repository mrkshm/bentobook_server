class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image_and_imageable

  def destroy
    Rails.logger.info "Attempting to destroy image #{@image.id} for #{@imageable.class} #{@imageable.id}"
    
    if @image.destroy
      Rails.logger.info "Image successfully destroyed"
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@imageable), notice: 'Image was successfully deleted.' }
        format.json { render json: { success: true } }
      end
    else
      Rails.logger.error "Failed to destroy image: #{@image.errors.full_messages}"
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@imageable), alert: 'Failed to delete image.' }
        format.json { render json: { success: false, errors: @image.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_image_and_imageable
    @image = Image.find(params[:id])
    @imageable = @image.imageable
    
    unless current_user_can_delete_image?
      Rails.logger.warn "User #{current_user.id} attempted to delete image #{@image.id} without permission"
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'You do not have permission to delete this image.' }
        format.json { render json: { success: false, errors: ['Permission denied'] }, status: :forbidden }
      end
    end
  end

  def current_user_can_delete_image?
    case @imageable
    when Restaurant, Visit
      @imageable.user == current_user
    else
      false
    end
  end

  def edit_polymorphic_path(imageable)
    case imageable
    when Restaurant
      edit_restaurant_path(id: imageable.id)
    when Visit
      edit_visit_path(id: imageable.id)
    else
      root_path
    end
  end
end

