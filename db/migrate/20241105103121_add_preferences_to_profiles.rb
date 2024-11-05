class AddPreferencesToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :preferred_language, :string, default: 'en'
    add_column :profiles, :preferred_theme, :string, default: 'light'
  end
end
