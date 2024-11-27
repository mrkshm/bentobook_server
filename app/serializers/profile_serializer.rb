class ProfileSerializer < BaseSerializer
  attributes :username, :first_name, :last_name, :about,
             :full_name, :display_name, :preferred_theme,
             :preferred_language, :created_at, :updated_at

  attribute :email do |profile|
    profile.user.email
  end

  attribute :avatar_urls do |profile|
    next nil unless profile.avatar.attached?
    next nil unless Rails.application.config.action_mailer.default_url_options&.dig(:host)

    {
      thumbnail: variant_url(profile.avatar, thumbnail_options),
      small: variant_url(profile.avatar, small_options),
      medium: variant_url(profile.avatar, medium_options),
      large: variant_url(profile.avatar, large_options),
      original: blob_url(profile.avatar)
    }
  end

  private

  def variant_url(attachment, options)
    return nil unless attachment.attached?
    return nil unless Rails.application.config.action_mailer.default_url_options&.dig(:host)

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment.variant(options),
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  rescue StandardError => e
    Rails.logger.error "Error generating variant URL: #{e.message}"
    nil
  end

  def blob_url(attachment)
    return nil unless attachment.attached?
    return nil unless Rails.application.config.action_mailer.default_url_options&.dig(:host)

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  rescue StandardError => e
    Rails.logger.error "Error generating blob URL: #{e.message}"
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
