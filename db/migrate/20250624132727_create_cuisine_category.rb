class CreateCuisineCategory < ActiveRecord::Migration[8.0]
  def change
    create_table :cuisine_categories do |t|
      t.string :name, null: false
      t.integer :display_order, default: 0
      t.timestamps
    end
    add_index :cuisine_categories, :name, unique: true
  end
end
