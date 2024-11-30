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
        status: "error",
        errors: [ {
          code: "not_found",
          detail: "Resource not found"
        } ]
      }, status: :not_found
    when ActiveRecord::ConnectionTimeoutError, ActiveRecord::StatementInvalid
      Rails.logger.error "Database error: #{e.class.name}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: {
        status: "error",
        errors: [ {
          code: "general_error",
          detail: "Database error"
        } ],
        meta: {
          timestamp: Time.current.iso8601
        }
      }, status: :internal_server_error
    else
      Rails.logger.error "Unexpected error: #{e.class.name}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: {
        status: "error",
        errors: [ {
          code: "general_error",
          detail: e.message
        } ],
        meta: {
          timestamp: Time.current.iso8601
        }
      }, status: :internal_server_error
    end
  end
end
