class MovePreferencesFromProfileToUser < ActiveRecord::Migration[8.0]
  def change
    # Add columns to users table
    add_column :users, :language, :string, default: 'en'
    add_column :users, :theme, :string, default: 'light'

    # Remove columns from profiles table
    remove_column :profiles, :preferred_language
    remove_column :profiles, :preferred_theme
  end
end
