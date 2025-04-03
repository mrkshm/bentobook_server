class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :allowlisted_jwts, dependent: :destroy
  has_many :restaurants
  has_many :google_restaurants, through: :restaurants
  has_many :memberships
  has_many :organizations, through: :memberships
  has_many :contacts
  has_many :visits
  has_many :images, as: :imageable, dependent: :destroy
  has_one :profile, dependent: :destroy
  after_create :ensure_profile
  after_create :create_organization

  has_many :lists, as: :owner, dependent: :destroy
  has_many :shares, foreign_key: :recipient_id
  has_many :created_shares, class_name: "Share", foreign_key: :creator_id
  has_many :shared_lists, -> { distinct },
           through: :shares,
           source: :shareable,
           source_type: "List",
           class_name: "List" do
    def pending
      where(shares: { status: :pending })
    end

    def accepted
      where(shares: { status: :accepted })
    end
  end

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
      'client_info' => current_sign_in_ip
    )
  end

  private

  def ensure_profile
    create_profile if profile.nil?
  end

  def create_organization
    org = Organization.new(id: id)
    org.save(validate: false)

    memberships.create!(organization: org)
  rescue => e
    Rails.logger.error "Failed to create organization for user #{id}: #{e.message}"
    raise e
  end
end
