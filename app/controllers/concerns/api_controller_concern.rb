module ApiControllerConcern
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
    respond_to :json
    before_action :set_default_format
    before_action :authenticate_user!

    private

    def set_default_format
      request.format = :json
    end

    def render_error(message, status, errors = nil)
      response = { error: message }
      response[:errors] = errors if errors
      render json: response, status: status
    end
  end
end
