class Profile < ApplicationRecord
  VALID_THEMES = %w[light dark cupcake black].freeze
  VALID_LANGUAGES = %w[en fr].freeze

  belongs_to :user

  has_one_attached :avatar

  validates :username, uniqueness: true, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }
  validates :preferred_theme, inclusion: { in: %w[light dark cupcake black] }
  validates :preferred_language, inclusion: { in: %w[en fr] }

  def full_name
    "#{first_name} #{last_name}".strip.presence
  end

  def display_name
    username.presence || full_name || user.email.split('@').first
  end
end
