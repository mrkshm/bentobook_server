module ApiErrorHandlerConcern
        extend ActiveSupport::Concern

        included do
          rescue_from ActiveRecord::RecordNotFound, with: :not_found
          rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
        end

        private

        def not_found(exception)
          render json: { error: exception.message }, status: :not_found
        end

        def unprocessable_entity(exception)
          render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
        end
  end