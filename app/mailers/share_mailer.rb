class ShareMailer < ApplicationMailer
  def share_notification(share)
    @share = share
    @creator = share.creator
    @source_organization = share.source_organization
    @target_organization = share.target_organization
    @shareable = share.shareable
    
    # Find admin users of the target organization to notify
    admin_emails = User.joins(:memberships)
                       .where(memberships: { organization: @target_organization, role: :admin })
                       .pluck(:email)
    
    # Fallback to organization's admin_email if no admin users found
    admin_emails = [@target_organization.admin_email] if admin_emails.empty?
    
    mail(
      to: admin_emails,
      subject: t('.subject', 
                creator: @creator.profile.display_name,
                organization: @source_organization.name)
    )
  end
end
