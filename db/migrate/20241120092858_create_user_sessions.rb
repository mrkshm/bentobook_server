class CreateUserSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :jti, null: false
      t.string :client_name, null: false
      t.datetime :last_used_at, null: false
      t.string :ip_address
      t.string :user_agent
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
