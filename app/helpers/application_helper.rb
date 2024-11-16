module ApplicationHelper
  include Pagy::Frontend
  include DaisyUiPagyHelper

  def notification_dot
    return unless current_user&.shares&.pending&.exists?
    
    tag.div class: "badge badge-error badge-xs"
  end
end
