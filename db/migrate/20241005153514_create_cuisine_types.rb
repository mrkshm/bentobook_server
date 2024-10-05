class CreateCuisineTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :cuisine_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :cuisine_types, :name, unique: true
  end
end
