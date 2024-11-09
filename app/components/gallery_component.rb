class GalleryComponent < ViewComponent::Base
  def initialize(images:, columns: 3)
    @images = images
    @columns = columns
  end
  
  private
  
  def grid_classes
    "grid gap-4 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-#{@columns}"
  end
  
  def image_classes
    "w-full h-64 object-cover rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200 cursor-pointer"
  end
end
