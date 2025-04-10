class AddEmailToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :email, :string

    # Data migration: Copy emails from users to their personal organizations
    reversible do |dir|
      dir.up do
        # For each user, find their organization and set the email
        execute <<-SQL
          UPDATE organizations o
          SET email = u.email
          FROM users u
          INNER JOIN memberships m ON m.user_id = u.id
          WHERE m.organization_id = o.id
        SQL
      end
    end
  end
end
