class GalleryModalComponent < ViewComponent::Base
  def initialize(image:, images:, total_count:, current_index:)
    @image = image
    @images = images
    @total_count = total_count
    @current_index = current_index
    @preload_images = calculate_preload_images
  end

  private

  def calculate_preload_images
    indices = [ @current_index - 1, @current_index + 1 ].select do |i|
      i >= 0 && i < @total_count
    end
    indices
  end

  def modal_id
    "gallery-modal-#{@current_index}"
  end

  def can_go_previous?
    @current_index > 0
  end

  def can_go_next?
    @current_index < @total_count - 1
  end

  # Adding process_image method for preloaded images
  def process_image(image, size = :large)
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

  def variant_options(size = :large)
    case size
    when :large
      { resize_to_limit: [ 1200, 800 ], format: :webp, saver: { quality: 80 } }
    else
      {}
    end
  end
end
