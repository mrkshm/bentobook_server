class AddProfileInformationToOrganization < ActiveRecord::Migration[8.0]
  def up
    # Add new columns to organizations
    add_column :organizations, :username, :string
    add_column :organizations, :name, :string
    add_column :organizations, :about, :text

    # Copy data from profiles to organizations
    execute <<-SQL
      UPDATE organizations o
      SET username = p.username,
          name = COALESCE(p.username, CONCAT(p.first_name, ' ', p.last_name)),
          about = p.about
      FROM profiles p
      WHERE o.id = p.user_id
    SQL

    # Copy avatar attachments if they exist
    execute <<-SQL
      UPDATE active_storage_attachments
      SET record_type = 'Organization',
          record_id = record_id
      WHERE record_type = 'Profile'
        AND name IN ('avatar_medium', 'avatar_thumbnail')
    SQL

    # Drop the profiles table
    drop_table :profiles
  end

  def down
    # Recreate profiles table
    create_table :profiles do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :username
      t.string :first_name
      t.string :last_name
      t.text :about
      t.timestamps
    end

    # Copy data back from organizations to profiles
    execute <<-SQL
      INSERT INTO profiles (user_id, username, about, created_at, updated_at)
      SELECT id, username, about, NOW(), NOW()
      FROM organizations
    SQL

    # Copy avatar attachments back
    execute <<-SQL
      UPDATE active_storage_attachments
      SET record_type = 'Profile',
          record_id = record_id
      WHERE record_type = 'Organization'
        AND name IN ('avatar_medium', 'avatar_thumbnail')
    SQL

    # Remove columns from organizations
    remove_column :organizations, :username
    remove_column :organizations, :name
    remove_column :organizations, :about
  end
end
