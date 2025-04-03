class MigrateTagsToOrganizations < ActiveRecord::Migration[7.0]
  def up
    # Update all existing taggings with their organization
    execute <<-SQL
      UPDATE taggings t
      SET tenant = r.organization_id::text
      FROM restaurants r
      WHERE t.taggable_type = 'Restaurant'
      AND t.taggable_id = r.id
    SQL
  end

  def down
    execute <<-SQL
      UPDATE taggings
      SET tenant = NULL
      WHERE taggable_type = 'Restaurant'
    SQL
  end
end
