class Profile < ApplicationRecord
  VALID_THEMES = %w[light dark cupcake black].freeze
  VALID_LANGUAGES = %w[en fr].freeze

  belongs_to :user

  has_one_attached :avatar

  validates :username, uniqueness: true, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }
  validates :preferred_theme, inclusion: { in: VALID_THEMES }, allow_nil: true
  validates :preferred_language, inclusion: { in: VALID_LANGUAGES }, allow_nil: true
  validates :about, length: { maximum: 500 }, allow_blank: true

  def avatar_url
    return nil unless avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      avatar,
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  rescue StandardError => e
    Rails.logger.error "Error generating avatar URL: #{e.message}"
    nil
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
end
