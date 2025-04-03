class FixAllowlistedJwts < ActiveRecord::Migration[7.1]
  def change
    # Add aud column
    add_column :allowlisted_jwts, :aud, :string

    # Make jti not null
    change_column_null :allowlisted_jwts, :jti, false

    # Drop existing index and create unique one
    remove_index :allowlisted_jwts, :jti
    add_index :allowlisted_jwts, :jti, unique: true

    # Add compound index
    add_index :allowlisted_jwts, [ :aud, :jti ]

    # Remove and re-add foreign key with cascade delete
    remove_foreign_key :allowlisted_jwts, :users
    add_foreign_key :allowlisted_jwts, :users, on_delete: :cascade
  end
end
