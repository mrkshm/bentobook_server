class AddOrganizationIdToRestaurants < ActiveRecord::Migration[8.0]
  def change
    add_column :restaurants, :organization_id, :bigint
    add_index :restaurants, :organization_id
    add_foreign_key :restaurants, :organizations
  end
end
