class AddDeviceInfoToUserSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :user_sessions, :device_type, :string
    add_column :user_sessions, :os_name, :string
    add_column :user_sessions, :os_version, :string
    add_column :user_sessions, :browser_name, :string
    add_column :user_sessions, :browser_version, :string
    add_column :user_sessions, :last_ip_address, :string
    add_column :user_sessions, :location_country, :string
    add_column :user_sessions, :suspicious, :boolean, default: false

    add_index :user_sessions, :device_type
    add_index :user_sessions, :suspicious
  end
end
