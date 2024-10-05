class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :city
      t.string :country
      t.string :phone
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
