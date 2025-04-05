class Profile < ApplicationRecord
  VALID_THEMES = %w[light dark cupcake black].freeze
  VALID_LANGUAGES = %w[en fr].freeze

  belongs_to :user

  has_one_attached :avatar_medium
  has_one_attached :avatar_thumbnail

  validates :username, uniqueness: true, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }
  validates :preferred_theme, inclusion: { in: VALID_THEMES }, allow_nil: true
  validates :preferred_language, inclusion: { in: VALID_LANGUAGES }, allow_nil: true
  validates :about, length: { maximum: 500 }, allow_blank: true

  def avatar_medium_url
    generate_url(avatar_medium)
  end

  def avatar_thumbnail_url
    generate_url(avatar_thumbnail)
  end

  def full_name
    "#{first_name} #{last_name}".strip.presence
  end

  def display_name
    username.presence || full_name || user.email.split("@").first
  end

  def theme
    preferred_theme || VALID_THEMES.first
  end

  def language
    preferred_language || VALID_LANGUAGES.first
  end

  private

  def generate_url(attachment)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  rescue StandardError => e
    Rails.logger.error "Error generating avatar URL: #{e.message}"
    nil
  end
end
