class ProfileSerializer < BaseSerializer
  attributes :username, :first_name, :last_name, :about,
             :full_name, :display_name, :preferred_theme,
             :preferred_language, :created_at, :updated_at

  attribute :email do |profile|
    profile.user.email
  end

  attribute :avatar_urls do |profile|
    next nil unless profile.avatar.attached?

    {
      thumbnail: variant_path(profile.avatar, thumbnail_options),
      small: variant_path(profile.avatar, small_options),
      medium: variant_path(profile.avatar, medium_options),
      large: variant_path(profile.avatar, large_options),
      original: blob_path(profile.avatar)
    }
  end

  private

  def variant_path(attachment, options)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_path(
      attachment.variant(options),
      only_path: true
    )
  rescue StandardError => e
    Rails.logger.error "Error generating variant path: #{e.message}"
    nil
  end

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

  def thumbnail_options
    {
      resize_to_fill: [ 100, 100 ],
      format: :webp,
      saver: { quality: 80 }
    }
  end

  def small_options
    {
      resize_to_limit: [ 300, 200 ],
      format: :webp,
      saver: { quality: 80 }
    }
  end

  def medium_options
    {
      resize_to_limit: [ 600, 400 ],
      format: :webp,
      saver: { quality: 80 }
    }
  end

  def large_options
    {
      resize_to_limit: [ 1200, 800 ],
      format: :webp,
      saver: { quality: 80 }
    }
  end
end
