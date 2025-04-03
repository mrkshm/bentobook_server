class AddOrganizationToLists < ActiveRecord::Migration[8.0]
  def change
    add_reference :lists, :organization, null: false, foreign_key: true
  end
end
