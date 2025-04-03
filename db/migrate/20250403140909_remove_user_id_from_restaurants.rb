class RemoveUserIdFromRestaurants < ActiveRecord::Migration[7.1]
  def change
    remove_reference :restaurants, :user, foreign_key: true
  end
end
