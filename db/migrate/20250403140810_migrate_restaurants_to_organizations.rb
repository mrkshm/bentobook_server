class MigrateRestaurantsToOrganizations < ActiveRecord::Migration[7.1]
  def up
    Restaurant.find_each do |restaurant|
      if restaurant.user_id
        restaurant.update_column(:organization_id, restaurant.user_id)
      end
    end
  end

  def down
    Restaurant.update_all(organization_id: nil)
  end
end
