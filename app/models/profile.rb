class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  validates :username, uniqueness: true, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }

  def full_name
    "#{first_name} #{last_name}".strip.presence
  end

  def display_name
    username.presence || full_name || user.email.split('@').first
  end

  def avatar_url
    if avatar.attached?
      Rails.env.test? ? avatar.attachment.filename.to_s : Rails.application.routes.url_helpers.url_for(avatar)
    end
  end
end
