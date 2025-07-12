class AddIndexOnBusinessStatusToRestaurants < ActiveRecord::Migration[8.0]
  def up
    Restaurant.where(business_status: nil).update_all(business_status: "OPERATIONAL")
    add_index :restaurants, :business_status
  end

  def down
    remove_index :restaurants, :business_status
  end
end
