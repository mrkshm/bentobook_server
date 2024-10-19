class ProfileSerializer
    include Alba::Resource
  
    attributes :id, :username, :first_name, :last_name, :about, :created_at, :updated_at, :full_name, :display_name

    attribute :avatar_url do |profile|
        profile.avatar_url
    end
end
