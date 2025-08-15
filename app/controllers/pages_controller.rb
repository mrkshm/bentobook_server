class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:home, :terms]

  def home
    if user_signed_in?
      redirect_to home_dashboard_path
      return
    end

    # The variant will be automatically set by ApplicationController
    respond_to do |format|
      format.html
    end
  end

  def terms
  end

  def privacy
  end
end
