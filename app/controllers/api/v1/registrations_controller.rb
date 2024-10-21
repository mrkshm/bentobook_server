module Api
    module V1
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
        skip_before_action :verify_authenticity_token
  
        def create
          build_resource(sign_up_params)
  
          if resource.save
            handle_successful_registration
          else
            handle_failed_registration
          end
        end
  
        private
  
        def handle_successful_registration
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
            token = request.env['warden-jwt_auth.token']
            render json: {
              status: { code: 200, message: 'Signed up successfully.' },
              data: UserSerializer.render(resource),
              token: token
            }, status: :ok
          else
            expire_data_after_sign_in!
            render json: {
              status: { code: 401, message: 'User created but not activated' },
              errors: ['User is not activated']
            }, status: :unauthorized
          end
        end
  
        def handle_failed_registration
          clean_up_passwords resource
          set_minimum_password_length
          render json: {
            status: { message: "User couldn't be created successfully." },
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
  
        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
end
