class Profile < ApplicationRecord

  belongs_to :user

  has_one_attached :avatar

  validates :username, uniqueness: true, allow_blank: true
  validates :first_name, :last_name, length: { maximum: 50 }

  after_commit :process_avatar_variants, if: :avatar_changed?

  def full_name
    "#{first_name} #{last_name}".strip.presence
  end

  def display_name
    username.presence || full_name || user.email.split('@').first
  end

  private

  def avatar_changed?
    avatar.attached? && attachment_changes['avatar'].present?
  end

  def process_avatar_variants
    generate_image_variants(:avatar)
  end
end
