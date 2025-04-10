module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      include Pagy::Backend

      before_action :set_user_and_organization, except: [ :search ]

      def show
        render json: ProfileSerializer.render_success({
          user: @user,
          organization: @organization
        })
      end

      def update
        user_updated = if profile_params[:first_name].present? || profile_params[:last_name].present? || 
                         profile_params[:language].present? || profile_params[:theme].present?
          @user.update(
            first_name: profile_params[:first_name],
            last_name: profile_params[:last_name],
            language: profile_params[:language],
            theme: profile_params[:theme]
          )
        else
          true
        end

        org_updated = if profile_params[:username].present? || profile_params[:name].present? || profile_params[:about].present?
          @organization.update(
            username: profile_params[:username],
            name: profile_params[:name],
            about: profile_params[:about]
          )
        else
          true
        end

        if user_updated && org_updated
          render json: ProfileSerializer.render_success({
            user: @user,
            organization: @organization
          })
        else
          errors = @user.errors.full_messages + @organization.errors.full_messages
          render json: ProfileSerializer.render_error(errors),
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
          @organization.avatar_medium.purge if @organization.avatar_medium.attached?
          @organization.avatar_thumbnail.purge if @organization.avatar_thumbnail.attached?
          
          # Attach new variants
          @organization.avatar_medium.attach(result[:variants][:medium])
          @organization.avatar_thumbnail.attach(result[:variants][:thumbnail])
          
          render json: ProfileSerializer.render_success({
            user: @user,
            organization: @organization
          })
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
        if @organization.avatar_medium.attached? || @organization.avatar_thumbnail.attached?
          @organization.avatar_medium.purge if @organization.avatar_medium.attached?
          @organization.avatar_thumbnail.purge if @organization.avatar_thumbnail.attached?
          render json: ProfileSerializer.render_success({
            user: @user,
            organization: @organization
          })
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
        organizations = Organization.joins(memberships: :user)
                          .where.not(users: { id: current_user.id })

        if query.present?
          organizations = organizations.where(
            "organizations.username ILIKE :query OR 
             organizations.name ILIKE :query OR 
             users.first_name ILIKE :query OR 
             users.last_name ILIKE :query OR 
             users.email ILIKE :query",
            query: "%#{query}%"
          )
        end

        organizations = organizations.order(:username)
        pagy, records = pagy(organizations, items: 20)

        Rails.logger.info "Search query: #{query.inspect}"
        Rails.logger.info "Organizations found: #{records.count}"
        Rails.logger.info "Pagy: #{pagy.inspect}"

        render json: {
          status: "success",
          data: records.map { |organization|
            # Find a representative user for this organization
            user = organization.users.first
            ProfileSerializer.render_success({
              user: user,
              organization: organization
            })[:data]
          }
        }
      rescue StandardError => e
        Rails.logger.error "Search error: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: ProfileSerializer.render_error([ e.message ]), status: :internal_server_error
      end

      def change_locale
        new_locale = params.require(:locale).to_s.strip

        if I18n.available_locales.map(&:to_s).include?(new_locale)
          @user.update!(language: new_locale)
          render json: ProfileSerializer.render_success({
            user: @user,
            organization: @organization
          })
        else
          render json: ProfileSerializer.render_error(
            ["Invalid locale. Valid options are: #{I18n.available_locales.join(', ')}"]
          ), status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: ProfileSerializer.render_error(["Missing locale parameter"]),
               status: :unprocessable_entity
      end

      def change_theme
        new_theme = params.require(:theme).to_s.strip

        if %w[light dark].include?(new_theme)
          @user.update!(theme: new_theme)
          render json: ProfileSerializer.render_success({
            user: @user,
            organization: @organization
          })
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
          :username, :name, :first_name, :last_name, :about,
          :theme, :language
        )
      end

      def set_user_and_organization
        @user = current_user
        @organization = current_user.organizations.first
      end
    end
  end
end
