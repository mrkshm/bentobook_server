class DropUserSessions < ActiveRecord::Migration[8.0]
  def change
    drop_table :user_sessions
  end
end
