class UpdateRestaurantCopy < ActiveRecord::Migration[7.0]
  def change
    remove_column :restaurant_copies, :user_id, :bigint
    add_reference :restaurant_copies, :organization, null: false, foreign_key: true
    add_index :restaurant_copies, [:organization_id, :restaurant_id], unique: true
  end
end
