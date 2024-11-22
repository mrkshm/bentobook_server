require "browser"

class UserSession < ApplicationRecord
  attr_accessor :token

  belongs_to :user

  validates :user, presence: true
  validates :jti, presence: true, uniqueness: true
  validates :client_name, presence: true
  validates :last_used_at, presence: true
  validates :ip_address, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  before_validation :set_last_used_at, on: :create
  before_validation :generate_jti, on: :create
  before_validation :set_device_info, on: :create
  before_save :track_ip_changes

  def browser_info
    @browser_info ||= Browser.new(user_agent) if user_agent.present?
  end

  def update_last_used(new_ip = nil)
    self.last_used_at = Time.current
    self.ip_address = new_ip if new_ip.present?
    save
  end

  def touch_last_used!
    update_last_used
  end

  def revoke!
    update!(active: false)
  end

  def device_info
    {
      type: device_type,
      device: "#{browser_name} #{browser_version}",
      platform: "#{os_name} #{os_version}".strip,
      client_name: client_name,
      last_used_at: last_used_at,
      last_ip: last_ip_address || ip_address
    }
  end

  class << self
    def create_session(user, client_info)
      user.user_sessions.create!(
        client_name: client_info[:name],
        ip_address: client_info[:ip_address] || "127.0.0.1",
        user_agent: client_info[:user_agent],
        active: true
      )
    end

    def revoke!(jti)
      session = find_by!(jti: jti)
      session.revoke!
    end

    def validate_token(payload)
      return false unless payload["jti"].present? && payload["sub"].present?

      session = find_by(jti: payload["jti"])
      return false unless session&.active? && session&.user_id == payload["sub"].to_i

      session.update_last_used
      true
    end
  end

  private

  def set_device_info
    return unless browser_info.present?

    self.device_type = if browser_info.device.mobile?
                        "mobile"
    elsif browser_info.device.tablet?
                        "tablet"
    else
                        "desktop"
    end

    # Strip device info from OS name
    self.os_name = browser_info.platform.name.split(" (").first
    self.os_version = browser_info.platform.version
    self.browser_name = browser_info.name
    self.browser_version = browser_info.version
  end

  def track_ip_changes
    return unless ip_address_changed? && ip_address_was.present?
    self.last_ip_address = ip_address_was
  end

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  def set_last_used_at
    self.last_used_at = Time.current
  end
end
