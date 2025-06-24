class AddCuisineCategoryToCuisineTypes < ActiveRecord::Migration[8.0]
  def change
    add_reference :cuisine_types, :cuisine_category, null: false, foreign_key: true
  end
end
