class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :username
      t.string :first_name
      t.string :last_name
      t.text :about

      t.timestamps
    end
  end
end
