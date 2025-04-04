class MigrateUserImagesToOrganizations < ActiveRecord::Migration[8.0]
  def up
    # Find all images that belong to users
    execute <<-SQL
      UPDATE images
      SET imageable_type = 'Organization',
          imageable_id = (
            SELECT organizations.id 
            FROM organizations 
            INNER JOIN memberships ON memberships.organization_id = organizations.id 
            WHERE memberships.user_id = images.imageable_id 
            LIMIT 1
          )
      WHERE imageable_type = 'User';
    SQL

    # Log any orphaned images (where we couldn't find an organization)
    orphaned_images = execute(<<-SQL).to_a
      SELECT id, imageable_id 
      FROM images 
      WHERE imageable_type = 'User' 
      AND imageable_id NOT IN (
        SELECT user_id 
        FROM memberships
      );
    SQL

    if orphaned_images.any?
      say "Found #{orphaned_images.length} orphaned images that couldn't be migrated:"
      orphaned_images.each do |img|
        say "Image ID: #{img['id']}, User ID: #{img['imageable_id']}"
      end
    end
  end

  def down
    say "This migration cannot be reversed as it would be impossible to determine which user owned which image"
    raise ActiveRecord::IrreversibleMigration
  end
end
