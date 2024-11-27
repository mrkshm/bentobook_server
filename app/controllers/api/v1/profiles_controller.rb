module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      include Pagy::Backend

      before_action :set_profile, except: [ :search, :change_locale ]

      def show
        render json: ProfileSerializer.render_success(@profile)
      end

      def update
        profile_update_result =
          Profile.transaction do
            @profile.update!(profile_params_without_avatar)

            Rails.logger.info "Avatar params: #{params.dig(:profile, :avatar).inspect}"
            Rails.logger.info "Full params: #{params.inspect}"

            if params.dig(:profile, :avatar).present?
              Rails.logger.info "Processing avatar with ImageHandlingService"
              result = ImageHandlingService.process_images(@profile, params, compress: true)
              Rails.logger.info "ImageHandlingService result: #{result.inspect}"
              raise ActiveRecord::RecordInvalid.new(@profile) unless result[:success]
            end

            true
          end

        render json: ProfileSerializer.render_success(@profile)
      rescue ActiveRecord::RecordInvalid
        render json: ProfileSerializer.render_error(@profile.errors),
               status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Profile update error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ProfileSerializer.render_error([ e.message ]),
               status: :internal_server_error
      end

      def search
        query = params[:query].to_s.strip
        profiles = Profile.joins(:user)
                        .where.not(users: { id: current_user.id })

        if query.present?
          profiles = profiles.where(
            "username ILIKE :query OR first_name ILIKE :query OR last_name ILIKE :query OR users.email ILIKE :query",
            query: "%#{query}%"
          )
        end

        profiles = profiles.order(:username)
        pagy, records = pagy(profiles, items: 20)

        Rails.logger.info "Search query: #{query.inspect}"
        Rails.logger.info "Profiles found: #{records.inspect}"
        Rails.logger.info "Pagy: #{pagy.inspect}"

        render json: {
          status: "success",
          data: records.map { |profile|
            ProfileSerializer.render_success(profile)[:data]
          }
        }
      rescue StandardError => e
        Rails.logger.error "Search error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ProfileSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      def change_locale
        new_locale = params[:locale].to_s.strip

        if Profile::VALID_LANGUAGES.include?(new_locale)
          current_user.profile.update!(preferred_language: new_locale)
          render json: ProfileSerializer.render_success(current_user.profile)
        else
          render json: ProfileSerializer.render_error(
            [ "Invalid locale. Valid options are: #{Profile::VALID_LANGUAGES.join(', ')}" ]
          ), status: :unprocessable_entity
        end
      end

      private

      def profile_params_without_avatar
        params.require(:profile).permit(
          :username, :first_name, :last_name, :about,
          :preferred_theme, :preferred_language
        )
      end

      def set_profile
        @profile = current_user&.profile || current_user&.create_profile!
      end
    end
  end
end
