class GalleryModalComponent < ViewComponent::Base
  def initialize(image:, total_count:, current_index:)
    @image = image
    @total_count = total_count
    @current_index = current_index
  end
  
  private
  
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
