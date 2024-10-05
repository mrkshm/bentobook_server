class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, null: false
      t.boolean :is_cover
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
