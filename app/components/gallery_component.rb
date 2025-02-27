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
    "w-full h-64 object-cover rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200"
  end

  def image_url(image)
    return nil unless image.present?

    if image.respond_to?(:file) && image.file.attached?
      url_for(image.file)
    elsif image.respond_to?(:attached?) && image.attached?
      url_for(image)
    else
      image
    end
  end
end
