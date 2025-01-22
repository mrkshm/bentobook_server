module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      include Pagy::Backend

      before_action :set_profile, except: [ :search, :change_locale ]

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
      rescue StandardError => e
        Rails.logger.error "Profile update error: #{e.message}"
        render json: ProfileSerializer.render_error([ e.message ]),
               status: :internal_server_error
      end

      def update_avatar
        begin
          Rails.logger.info "Processing avatar with ImageHandlingService"
          result = ImageHandlingService.process_images(@profile, params, compress: true)

          if result[:success]
            render json: ProfileSerializer.render_success(@profile)
          else
            render json: ProfileSerializer.render_error([ "Failed to update avatar" ]),
                   status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error "Avatar update error: #{e.message}"
          render json: ProfileSerializer.render_error([ e.message ]),
                 status: :internal_server_error
        end
      end

      def destroy_avatar
        if @profile.avatar.attached?
          @profile.avatar.purge
          render json: ProfileSerializer.render_success(@profile)
        else
          render json: ProfileSerializer.render_error([ "No avatar to delete" ]),
                 status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Avatar deletion error: #{e.message}"
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
            "Invalid locale. Valid options are: #{Profile::VALID_LANGUAGES.join(', ')}",
            :unprocessable_entity
          ), status: :unprocessable_entity
        end
      end

      def change_theme
        new_theme = params[:theme].to_s.strip

        if Profile::VALID_THEMES.include?(new_theme)
          current_user.profile.update!(preferred_theme: new_theme)
          render json: ProfileSerializer.render_success(current_user.profile)
        else
          render json: ProfileSerializer.render_error(
            "Invalid theme. Please try again.",
            :unprocessable_entity
          ), status: :unprocessable_entity
        end
      end

      private

      def profile_params
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
