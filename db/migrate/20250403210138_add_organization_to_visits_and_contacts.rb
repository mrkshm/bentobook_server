class AddOrganizationToVisitsAndContacts < ActiveRecord::Migration[7.0]
  def change
    add_reference :visits, :organization, null: true, foreign_key: true
    add_reference :contacts, :organization, null: true, foreign_key: true

    # Update existing visits with their restaurant's organization
    execute <<-SQL
      UPDATE visits v
      SET organization_id = r.organization_id
      FROM restaurants r
      WHERE v.restaurant_id = r.id
    SQL

    # Update existing contacts with their user's first organization
    # This is a temporary solution - you might want to handle this differently
    execute <<-SQL
      UPDATE contacts c
      SET organization_id = (
        SELECT m.organization_id#{' '}
        FROM memberships m#{' '}
        WHERE m.user_id = c.user_id#{' '}
        LIMIT 1
      )
    SQL

    # Make organization_id not nullable after data migration
    change_column_null :visits, :organization_id, false
    change_column_null :contacts, :organization_id, false

    # Remove user_id from visits as it's no longer needed
    remove_reference :visits, :user, foreign_key: true

    # Add unique constraint for contact names within an organization
    remove_index :contacts, [ :name, :user_id ], if_exists: true
    add_index :contacts, [ :name, :organization_id ], unique: true
  end
end
