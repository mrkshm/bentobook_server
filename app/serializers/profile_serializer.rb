class ProfileSerializer < BaseSerializer
  def self.render_success(profile)
    {
      status: { code: 200, message: "Success" },
      data: {
        type: "profile",
        id: profile.id.to_s,
        attributes: {
          username: profile.username,
          first_name: profile.first_name,
          last_name: profile.last_name,
          about: profile.about,
          full_name: profile.full_name,
          display_name: profile.display_name,
          email: profile.user.email,
          avatar_url: profile.avatar_url,
          created_at: profile.created_at,
          updated_at: profile.updated_at
        }
      }
    }
  end

  def self.render_error(errors)
    {
      status: {
        code: 422,
        message: "Validation failed"
      },
      errors: errors.full_messages.map { |msg|
        {
          code: "general_error",
          detail: msg
        }
      }
    }
  end
end
