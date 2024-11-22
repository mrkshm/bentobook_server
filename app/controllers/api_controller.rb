class ApiController < ActionController::API
  include ActionController::MimeResponds

  before_action :set_default_format
  rescue_from StandardError, with: :handle_error

  private

  def set_default_format
    request.format = :json unless params[:format]
  end

  def handle_error(e)
    case e
    when ActiveRecord::RecordNotFound
      render json: {
        status: {
          code: 404,
          message: "Resource not found"
        }
      }, status: :not_found
    else
      render json: {
        status: {
          code: 500,
          message: "Internal server error"
        }
      }, status: :internal_server_error
    end
  end
end
