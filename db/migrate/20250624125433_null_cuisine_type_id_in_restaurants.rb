class NullCuisineTypeIdInRestaurants < ActiveRecord::Migration[8.0]
  def up
    Restaurant.update_all(cuisine_type_id: nil)
  end

  def down
  end
end
