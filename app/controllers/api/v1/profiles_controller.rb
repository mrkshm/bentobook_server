module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      include Pagy::Backend

      before_action :set_profile, except: [ :search ]

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
        unless params[:avatar]
          return render json: ProfileSerializer.render_error(["No avatar provided"]),
                        status: :unprocessable_entity
        end

        result = PreprocessAvatarService.call(params[:avatar])

        if result[:success]
          # Remove old avatars if they exist
          @profile.avatar_medium.purge if @profile.avatar_medium.attached?
          @profile.avatar_thumbnail.purge if @profile.avatar_thumbnail.attached?
          
          # Attach new variants
          @profile.avatar_medium.attach(result[:variants][:medium])
          @profile.avatar_thumbnail.attach(result[:variants][:thumbnail])
          
          render json: ProfileSerializer.render_success(@profile)
        else
          render json: ProfileSerializer.render_error([result[:error]]),
                 status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Avatar update error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ProfileSerializer.render_error([ e.message ]),
               status: :internal_server_error
      end

      def destroy_avatar
        if @profile.avatar_medium.attached? || @profile.avatar_thumbnail.attached?
          @profile.avatar_medium.purge if @profile.avatar_medium.attached?
          @profile.avatar_thumbnail.purge if @profile.avatar_thumbnail.attached?
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
        new_locale = params.require(:locale).to_s.strip

        if Profile::VALID_LANGUAGES.include?(new_locale)
          @profile.update!(preferred_language: new_locale)
          render json: ProfileSerializer.render_success(@profile)
        else
          render json: ProfileSerializer.render_error(
            ["Invalid locale. Valid options are: #{Profile::VALID_LANGUAGES.join(', ')}"]
          ), status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: ProfileSerializer.render_error(["Missing locale parameter"]),
               status: :unprocessable_entity
      end

      def change_theme
        new_theme = params.require(:theme).to_s.strip

        if Profile::VALID_THEMES.include?(new_theme)
          @profile.update!(preferred_theme: new_theme)
          render json: ProfileSerializer.render_success(@profile)
        else
          render json: ProfileSerializer.render_error(
            ["Invalid theme. Please try again."]
          ), status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: ProfileSerializer.render_error(["Missing theme parameter"]),
               status: :unprocessable_entity
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
