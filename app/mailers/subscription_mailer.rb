class SubscriptionMailer < ApplicationMailer
  def confirmation_email(email)
    @email = email
    mail(
      to: "mrks.heumann@gmail.com",
      subject: "New Bentobook Subscription"
    )
  end
end
