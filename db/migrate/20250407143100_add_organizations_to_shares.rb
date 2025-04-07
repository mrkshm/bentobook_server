class AddOrganizationsToShares < ActiveRecord::Migration[8.0]
  def change
    # Add organization references
    add_reference :shares, :source_organization, null: false, foreign_key: { to_table: :organizations }
    add_reference :shares, :target_organization, null: false, foreign_key: { to_table: :organizations }

    # Add a composite index for better query performance
    add_index :shares, [ :source_organization_id, :target_organization_id, :shareable_type, :shareable_id ],
             name: 'index_shares_on_organizations_and_shareable'

    # Remove the recipient_id column as it's replaced by target_organization_id
    remove_reference :shares, :recipient, foreign_key: { to_table: :users }, index: true
  end
end
