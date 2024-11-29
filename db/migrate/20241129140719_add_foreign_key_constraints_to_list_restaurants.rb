class AddForeignKeyConstraintsToListRestaurants < ActiveRecord::Migration[7.1]
  def up
    # First, remove any orphaned records
    execute <<-SQL
      DELETE FROM list_restaurants#{' '}
      WHERE list_id NOT IN (SELECT id FROM lists)
         OR restaurant_id NOT IN (SELECT id FROM restaurants)
    SQL

    # Add foreign key constraints with cascade delete
    add_foreign_key :list_restaurants, :lists,
                    on_delete: :cascade,
                    name: 'fk_list_restaurants_list'
    add_foreign_key :list_restaurants, :restaurants,
                    on_delete: :cascade,
                    name: 'fk_list_restaurants_restaurant'
  end

  def down
    remove_foreign_key :list_restaurants, name: 'fk_list_restaurants_list'
    remove_foreign_key :list_restaurants, name: 'fk_list_restaurants_restaurant'
  end
end
