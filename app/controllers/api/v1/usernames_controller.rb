module Api
    module V1
      class UsernamesController < ApplicationController
        def verify
          username = params[:username].to_s
          
          if username.blank? || username == "{}"
            render json: BaseSerializer.render_error("Username parameter is required", :bad_request), 
                   status: :bad_request
            return
          end
          
          exists = Profile.exists?(username: username)
          
          verification = OpenStruct.new(
            id: 0,
            available: !exists,
            username: username
          )
          
          render json: UsernameVerificationSerializer.render_success(
            verification,
            meta: {
              message: exists ? "Username is taken" : "Username is available"
            }
          )
        end
      end
    end
  end