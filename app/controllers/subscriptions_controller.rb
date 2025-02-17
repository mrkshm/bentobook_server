class SubscriptionsController < ApplicationController
  def create
    # For now, we'll just send an email
    SubscriptionMailer.confirmation_email(params[:email]).deliver_later
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("subscription_form",
          partial: "subscriptions/success")
      end
    end
  end
end
