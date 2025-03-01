class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)

    # Simple redirect handling that works for both Turbo and regular requests
    redirect_to after_sign_in_path_for(resource), notice: t(".signed_in")
  end

  def respond_to_on_destroy
    # Keep this simple too
    redirect_to after_sign_out_path_for(resource_name), notice: t(".signed_out")
  end

  private

  def after_sign_in_path_for(resource)
    if turbo_native_app?
      home_dashboard_path(locale: nil)
    else
      restaurants_path(locale: nil)
    end
  end

  def turbo_native_app?
    request.user_agent&.include?("Turbo Native")
  end
end
