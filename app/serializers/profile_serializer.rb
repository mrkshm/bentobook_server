class ProfileSerializer < BaseSerializer
  attributes :username, :first_name, :last_name, :about,
             :full_name, :display_name, :preferred_theme,
             :preferred_language, :created_at, :updated_at

  attribute :email do |profile|
    profile.user.email
  end

  attribute :avatar_urls do |profile|
    urls = {}
    
    if profile.avatar_thumbnail.attached?
      urls[:thumbnail] = blob_path(profile.avatar_thumbnail)
    end
    
    if profile.avatar_medium.attached?
      urls[:medium] = blob_path(profile.avatar_medium)
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
