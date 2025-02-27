class GalleryComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  def initialize(images:, columns: 3, use_originals: true)
    @images = images.is_a?(Array) ? images : Array(images)
    @columns = columns
    @use_originals = use_originals
  end

  # Generate image URL during rendering, when controller is available
  def image_url(image, size = :medium)
    return nil unless valid_image?(image)

    # Bypass variant processing if use_originals is true
    if @use_originals
      return original_image_url(image)
    end

    if image.respond_to?(:file) && image.file.attached?
      # For polymorphic Image model
      rails_blob_url(image.file.variant(variant_options(size)))
    elsif image.respond_to?(:attached?) && image.attached?
      # For direct ActiveStorage attachments
      rails_blob_url(image.variant(variant_options(size)))
    elsif image.is_a?(ActiveStorage::VariantWithRecord) || image.is_a?(ActiveStorage::Variant)
      # For variants that are already processed
      rails_blob_url(image)
    end
  end

  # Get direct URL to original image without variant processing
  def original_image_url(image)
    if image.respond_to?(:file) && image.file.attached?
      # For polymorphic Image model
      rails_blob_url(image.file)
    elsif image.respond_to?(:attached?) && image.attached?
      # For direct ActiveStorage attachments
      rails_blob_url(image)
    elsif image.is_a?(ActiveStorage::VariantWithRecord) || image.is_a?(ActiveStorage::Variant)
      # For variants that are already processed
      rails_blob_url(image)
    end
  end

  def valid_image?(image)
    return false unless image.present?

    # Handle polymorphic Image model
    if image.respond_to?(:file) && image.file.attached?
      return true
    end

    # Handle direct ActiveStorage attachments
    if image.respond_to?(:attached?) && image.attached?
      return true
    end

    # Handle ActiveStorage variants
    image.is_a?(ActiveStorage::VariantWithRecord) ||
    image.is_a?(ActiveStorage::Variant)
  end

  private

  def grid_classes
    "grid gap-4 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-#{@columns}"
  end

  def image_classes
    "w-full h-64 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200"
  end

  def variant_options(size)
    case size
    when :thumbnail
      { resize_to_fill: [ 100, 100 ], format: :webp, saver: { quality: 80 } }
    when :small
      { resize_to_limit: [ 300, 200 ], format: :webp, saver: { quality: 80 } }
    when :medium
      { resize_to_limit: [ 600, 400 ], format: :webp, saver: { quality: 80 } }
    when :large
      { resize_to_limit: [ 1200, 800 ], format: :webp, saver: { quality: 80 } }
    when :original
      {} # Use the original format without resizing
    else
      {}
    end
  end
end
