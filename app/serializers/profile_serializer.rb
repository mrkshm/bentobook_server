class ProfileSerializer < BaseSerializer
  class VirtualProfile
    attr_reader :id, :user, :organization
    
    def initialize(user, organization)
      @id = user.id # Use the user's id as the profile id
      @user = user
      @organization = organization
    end
    
    def class
      # This is needed for BaseSerializer's type field
      OpenStruct.new(name: 'Profile')
    end
  end
  
  def self.render_success(data, meta: {}, **options)
    # Create a virtual profile from the user and organization
    if data.is_a?(Hash) && data[:user] && data[:organization]
      virtual_profile = VirtualProfile.new(data[:user], data[:organization])
      super(virtual_profile, meta: meta, **options)
    else
      super(data, meta: meta, **options)
    end
  end

  attribute :email do |profile|
    profile.user.email
  end

  attribute :username do |profile|
    profile.organization.username
  end

  attribute :name do |profile|
    profile.organization.name
  end

  attribute :about do |profile|
    profile.organization.about
  end

  attribute :first_name do |profile|
    profile.user.first_name
  end

  attribute :last_name do |profile|
    profile.user.last_name
  end

  attribute :full_name do |profile|
    profile.user.full_name
  end

  attribute :display_name do |profile|
    profile.user.display_name
  end

  attribute :theme do |profile|
    profile.user.theme
  end

  attribute :language do |profile|
    profile.user.language
  end

  attribute :created_at do |profile|
    profile.user.created_at
  end

  attribute :updated_at do |profile|
    [profile.user.updated_at, profile.organization.updated_at].max
  end

  attribute :avatar_urls do |profile|
    urls = {}
    organization = profile.organization

    if organization.avatar_thumbnail.attached?
      urls[:thumbnail] = blob_path(organization.avatar_thumbnail)
    end

    if organization.avatar_medium.attached?
      urls[:medium] = blob_path(organization.avatar_medium)
    end

    urls.present? ? urls : nil
  end

  private

  def blob_path(attachment)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_path(
      attachment,
      only_path: true
    )
  rescue StandardError => e
    Rails.logger.error "Error generating blob path: #{e.message}"
    nil
  end
end
