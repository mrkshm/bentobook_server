class CreateVisitContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :visit_contacts do |t|
      t.references :visit, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
