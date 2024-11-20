class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :user_sessions, dependent: :destroy
  has_many :restaurants
  has_many :google_restaurants, through: :restaurants
  has_many :memberships
  has_many :organizations, through: :memberships
  has_many :contacts
  has_many :visits
  has_many :images, as: :imageable, dependent: :destroy
  has_one :profile, dependent: :destroy
  after_create :ensure_profile

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

  # Session management methods
  def create_session!(client_name:, ip_address: nil, user_agent: nil)
    user_sessions.create!(
      client_name: client_name,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def active_sessions
    user_sessions.active
  end

  def revoke_session!(jti)
    user_sessions.revoke!(jti)
  end

  def revoke_all_sessions!
    user_sessions.active.update_all(active: false)
  end

  private

  def ensure_profile
    create_profile if profile.nil?
  end

  # Explicit JWT revocation check
  def jwt_revoked?(payload, user)
    # Check if the token's JTI exists in revoked user_sessions
    user_sessions.exists?(jti: payload['jti'], active: false)
  end
end
