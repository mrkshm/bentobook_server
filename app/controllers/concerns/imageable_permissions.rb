module ImageablePermissions
  extend ActiveSupport::Concern

  def current_user_can_modify_imageable?(imageable)
    return false unless imageable && Current.organization

    case imageable
    when Visit, Contact, Restaurant
      imageable.organization_id == Current.organization.id
    else
      false
    end
  end
end
