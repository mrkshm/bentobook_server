# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string
#  language               :string           default("en")
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  theme                  :string           default("light")
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
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
