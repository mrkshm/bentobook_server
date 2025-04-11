class AddCategoryToCuisineTypes < ActiveRecord::Migration[8.0]
  def change
    add_reference :cuisine_types, :category, foreign_key: true
    add_column :cuisine_types, :display_order, :integer, default: 0
    add_index :cuisine_types, :display_order
  end
end
