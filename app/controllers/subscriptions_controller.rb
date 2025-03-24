class SubscriptionsController < ApplicationController
  def create
    # Check honeypot
    if params[:website].present?
      head :ok
      return
    end

    # Verify reCAPTCHA
    unless verify_recaptcha(action: "subscription", minimum_score: 0.5)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "subscription_form",
            partial: "pages/subscription_form",
            locals: { error: t("pages.home.subscriptions.create.captcha_failed") }
          )
        }
      end
      return
    end

    # Basic format validation
    unless email_format_valid?(params[:email])
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "subscription_form",
            partial: "pages/subscription_form",
            locals: { error: t("pages.home.subscriptions.create.invalid_email") }
          )
        }
      end
      return
    end

    # Create subscription
    SubscriptionMailer.confirmation_email(params[:email]).deliver_later

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("subscription_form",
          partial: "subscriptions/success")
      end
    end
  end

  private

  def email_format_valid?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end
