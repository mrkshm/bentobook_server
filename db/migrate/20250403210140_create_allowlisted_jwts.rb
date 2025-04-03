class CreateAllowlistedJwts < ActiveRecord::Migration[7.1]
  def change
    drop_table :allowlisted_jwts if table_exists?(:allowlisted_jwts)

    create_table :allowlisted_jwts do |t|
      t.string :jti, null: false
      t.string :aud
      t.datetime :exp, null: false
      t.references :user, foreign_key: { on_delete: :cascade }, null: false

      t.timestamps
    end

    add_index :allowlisted_jwts, :jti, unique: true
    add_index :allowlisted_jwts, [ :aud, :jti ]
  end
end
