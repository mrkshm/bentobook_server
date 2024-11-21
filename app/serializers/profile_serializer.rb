class ProfileSerializer < BaseSerializer
    attributes :username,
              :first_name,
              :last_name,
              :about,
              :full_name,
              :display_name,
              :created_at,
              :updated_at

    attribute :email do |profile|
      profile.user.email
    end

    attribute :avatar_url do |profile|
      profile.avatar_url
    end
end
