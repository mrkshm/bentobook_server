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
    return unless image&.file&.attached?

    image.file.variant(variant_options(size))
  end

  def variant_options(size = :medium)
    case size
    when :medium
      { resize_to_limit: [ 600, 400 ], format: :jpg }
    when :large
      { resize_to_limit: [ 1200, 800 ], format: :jpg }
    end
  end
end
