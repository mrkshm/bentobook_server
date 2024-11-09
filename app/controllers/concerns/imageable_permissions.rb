module ImageablePermissions
  extend ActiveSupport::Concern

  def current_user_can_modify_imageable?(imageable)
    case imageable
    when Visit, Contact, Restaurant
      imageable.user == current_user
    else
      false
    end
  end
end
