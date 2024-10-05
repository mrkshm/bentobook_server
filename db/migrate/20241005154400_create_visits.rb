class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.date :date
      t.string :title
      t.text :notes
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.integer :rating
      t.integer :price_paid_cents
      t.string :price_paid_currency

      t.timestamps
    end
  end
end
