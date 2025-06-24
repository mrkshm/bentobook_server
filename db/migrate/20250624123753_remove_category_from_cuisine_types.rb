class RemoveCategoryFromCuisineTypes < ActiveRecord::Migration[8.0]
  def up
    remove_reference :cuisine_types, :category, null: false, foreign_key: true
  end

  def down
  end
end
