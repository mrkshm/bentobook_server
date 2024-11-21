class UserSession < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :jti, presence: true, uniqueness: true
  validates :client_name, presence: true
  validates :last_used_at, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  before_validation :set_last_used_at, on: :create
  before_validation :generate_jti, on: :create

  class << self
    def validate_token(payload)
      return false unless payload["jti"].present? && payload["sub"].present?

      session = find_by(jti: payload["jti"])
      return false unless session&.active? && session.user_id == payload["sub"].to_i

      # Force timestamp update
      session.update_columns(last_used_at: Time.zone.now)
      true
    end

    def create_session(user, client_info)
      create!(
        user: user,
        client_name: client_info[:name],
        active: true
      )
    end

    def revoke!(jti)
      find_by!(jti: jti).update!(active: false)
    end
  end

  def touch_last_used!
    update_columns(last_used_at: Time.zone.now)
  end

  def revoke!
    update!(active: false)
  end

  private

  def set_last_used_at
    self.last_used_at ||= Time.current
  end

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end
end
