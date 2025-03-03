class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image_and_imageable, only: [ :destroy ]
  before_action :set_restaurant, only: [ :new, :create ]
  skip_before_action :ensure_locale_matches_url, only: [ :create ]

  def new
    # Just renders the view for image upload
  end

  def create
    if params[:images].present?
      begin
        images_added = 0
        blobs_to_purge = []

        ActiveRecord::Base.transaction do
          params[:images].each do |image|
            next if image.blank?

            # Create blob and upload file to S3 with pre-calculated checksum
            blob = create_blob_with_checksum(image)
            blobs_to_purge << blob # Track for cleanup in case of error

            # Create image record and attach blob
            @restaurant.images.create!(file: blob)
            images_added += 1
          end

          # If we get here, clear the blobs_to_purge list (all good)
          blobs_to_purge.clear
        end

        # All uploads successful, redirect to restaurant page
        redirect_to restaurant_path(id: @restaurant.id, locale: nil),
          notice: t("images.notices.uploaded", count: images_added)
      rescue StandardError => e
        # Clean up any orphaned blobs if transaction failed
        blobs_to_purge.each(&:purge) if blobs_to_purge.any?

        Rails.logger.error "Image upload failed: #{e.message}"
        flash[:alert] = t("images.errors.processing_failed")
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = t("images.errors.none_selected")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.info "Attempting to destroy image #{@image.id} for #{@imageable.class} #{@imageable.id}"

    if @image.destroy
      Rails.logger.info "Image successfully destroyed"
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@imageable), notice: "Image was successfully deleted." }
        format.json { render json: { success: true } }
      end
    else
      Rails.logger.error "Failed to destroy image: #{@image.errors.full_messages}"
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@imageable), alert: "Failed to delete image." }
        format.json { render json: { success: false, errors: @image.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def bulk_destroy
    image_ids = params[:image_ids]

    unless image_ids.present?
      render json: { error: "No images selected" }, status: :unprocessable_entity
      return
    end

    images = Image.where(id: image_ids).includes(:imageable)

    # Check permissions
    unless images.all? { |image| image.imageable.user_id == current_user.id }
      render json: { error: "Unauthorized" }, status: :forbidden
      return
    end

    begin
      Image.transaction do
        images.each(&:destroy!)
      end

      render json: {
        success: true,
        deleted_count: images.size
      }
    rescue StandardError => e
      Rails.logger.error "Bulk image deletion failed: #{e.message}"
      render json: {
        error: "Failed to delete some images. Please try again."
      }, status: :unprocessable_entity
    end
  end

  private

  def create_blob_with_checksum(file)
    service = ActiveStorage::Blob.service

    # Generate a timestamp-based key that matches what set_filename would create
    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    original_filename = file.original_filename
    extension = File.extname(original_filename).downcase
    basename = File.basename(original_filename, extension)
    truncated_name = basename.truncate(12, omission: "")
    key = "#{timestamp}_#{truncated_name}#{extension}"

    # Calculate checksum manually in advance
    checksum = Digest::MD5.file(file.tempfile.path).base64digest

    # Create blob with the timestamp-based key
    blob = ActiveStorage::Blob.create!(
      key: key,
      filename: file.original_filename,  # Keep original filename for display
      byte_size: file.size,
      checksum: checksum,
      content_type: file.content_type,
      service_name: service.name
    )

    # Upload the file with the same key
    service.upload(
      key,
      file,
      content_type: file.content_type
    )

    blob
  end

  def set_restaurant
    @restaurant = current_user.restaurants.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path(locale: nil), alert: t("errors.restaurants.not_found")
  end

  def set_image_and_imageable
    @image = Image.find(params[:id])
    @imageable = @image.imageable

    unless current_user_can_delete_image?
      Rails.logger.warn "User #{current_user.id} attempted to delete image #{@image.id} without permission"
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You do not have permission to delete this image." }
        format.json { render json: { success: false, errors: [ "Permission denied" ] }, status: :forbidden }
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
      edit_restaurant_path(id: imageable.id, locale: nil)
    when Visit
      edit_visit_path(id: imageable.id, locale: nil)
    else
      root_path
    end
  end
end
