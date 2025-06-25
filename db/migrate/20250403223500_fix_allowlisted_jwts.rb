class FixAllowlistedJwts < ActiveRecord::Migration[7.1]
  def change
    # Add aud column
    unless column_exists?(:allowlisted_jwts, :aud)
      add_column :allowlisted_jwts, :aud, :string
    end

    # Make jti not null
    change_column_null :allowlisted_jwts, :jti, false if column_exists?(:allowlisted_jwts, :jti)

    # Ensure unique index on jti
    if index_exists?(:allowlisted_jwts, :jti)
      remove_index :allowlisted_jwts, :jti
    end
    add_index :allowlisted_jwts, :jti, unique: true unless index_exists?(:allowlisted_jwts, :jti, unique: true)

    # Compound index on aud + jti
    unless index_exists?(:allowlisted_jwts, [ :aud, :jti ])
      add_index :allowlisted_jwts, [ :aud, :jti ]
    end

    # Foreign key with cascade delete
    if foreign_key_exists?(:allowlisted_jwts, :users)
      remove_foreign_key :allowlisted_jwts, :users
    end
    add_foreign_key :allowlisted_jwts, :users, on_delete: :cascade unless foreign_key_exists?(:allowlisted_jwts, :users, on_delete: :cascade)
  end
end
