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

  def self.revoke!(jti)
    find_by!(jti: jti).update!(active: false)
  end

  def touch_last_used!
    update!(last_used_at: Time.current)
  end

  private

  def set_last_used_at
    self.last_used_at ||= Time.current
  end

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end
end
