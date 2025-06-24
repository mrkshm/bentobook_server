class DropCategoriesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :categories
  end

  def down
  end
end
