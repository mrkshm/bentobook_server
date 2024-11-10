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
    indices = [@current_index - 1, @current_index + 1].select do |i|
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
end
