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
end
