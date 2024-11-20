class AddUserSessionsIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :user_sessions, :jti, unique: true
    add_index :user_sessions, [ :user_id, :client_name ]
    add_index :user_sessions, :last_used_at
    add_index :user_sessions, :active
  end
end
