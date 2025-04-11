class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :allowlisted_jwts, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :created_lists, class_name: "List", foreign_key: "creator_id"

  # Validations
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true

  # Theme and language preferences
  attribute :theme, :string, default: "light"
  attribute :language, :string, default: "en"

  # Name methods
  def full_name
    return nil if first_name.blank? && last_name.blank?
    [ first_name, last_name ].compact.join(" ")
  end

  def display_name
    full_name.presence || email
  end

  def ensure_organization
    return if organizations.exists?

    # Create a new organization for the user
    organization = Organization.create!(email: email)
    memberships.create!(organization: organization)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create organization for user #{id}: #{e.message}"
    raise
  end

  after_create :ensure_organization

  # Development convenience methods
  def confirmation_required?
    Rails.env.production?
  end

  def lock_access!
    Rails.env.production? ? super : nil
  end

  # JWT callback - add custom claims
  def on_jwt_dispatch(_token, payload)
    payload.merge!(
      "client_info" => current_sign_in_ip
    )
  end

  private

  def jwt_payload
    {
      user_id: id,
      email: email,
      confirmed: confirmed?
    }
  end
end
