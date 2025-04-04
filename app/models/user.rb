class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :allowlisted_jwts, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_one :profile, dependent: :destroy
  
  # Lists the user created
  has_many :created_lists, class_name: "List", foreign_key: :creator_id
  # Lists shared with the user
  has_many :shares, foreign_key: :recipient_id

  after_create :ensure_profile
  after_create :create_organization

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

  def ensure_profile
    create_profile if profile.nil?
  end

  def create_organization
    org = Organization.new
    org.save!
    memberships.create!(organization: org)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create organization for user #{id}: #{e.message}"
    raise
  end
end
