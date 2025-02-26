class GalleryComponent < ViewComponent::Base
  def initialize(images:, columns: 3)
    @images = images.is_a?(Array) ? images : Array(images)
    @columns = columns
  end

  private

  def grid_classes
    "grid gap-4 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-#{@columns}"
  end

  def image_classes
    "w-full h-64 object-cover rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200 cursor-pointer"
  end

  def process_image(image, size = :medium)
    # Handle nil images
    return nil unless image.present?

    # For our polymorphic Image model
    if image.respond_to?(:file) && image.file.attached?
      return image.file.variant(variant_options(size))
    end

    # For direct ActiveStorage attachments
    if image.respond_to?(:attached?) && image.attached?
      return image.variant(variant_options(size))
    end

    # For variants or other attachment types
    image
  end

  def variant_options(size = :medium)
    case size
    when :medium
      { resize_to_limit: [ 600, 400 ], format: :webp, saver: { quality: 80 } }
    when :large
      { resize_to_limit: [ 1200, 800 ], format: :webp, saver: { quality: 80 } }
    end
  end
end
