class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:home, :terms]

  def home
    # The variant will be automatically set by ApplicationController
    respond_to do |format|
      format.html
    end
  end

  def terms
  end
end
