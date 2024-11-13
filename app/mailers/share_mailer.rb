class ShareMailer < ApplicationMailer
  def share_notification(share)
    @share = share
    @recipient = share.recipient
    @creator = share.creator
    @shareable = share.shareable

    mail(
      to: @recipient.email,
      subject: t('.subject', creator: @creator.profile.display_name)
    )
  end
end
