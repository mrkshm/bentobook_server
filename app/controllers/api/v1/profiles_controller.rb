module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      before_action :set_profile, only: [ :show, :update ]

      def show
        render json: ProfileSerializer.render_success(@profile)
      end

      def update
        if @profile.update(profile_params)
          render json: ProfileSerializer.render_success(@profile)
        else
          render json: ProfileSerializer.render_error(@profile.errors),
                 status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:profile).permit(:username, :first_name, :last_name, :about, :avatar)
      end

      def set_profile
        @profile = current_user&.profile || current_user&.create_profile!
      end
    end
  end
end
