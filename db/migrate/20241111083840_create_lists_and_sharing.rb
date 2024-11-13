class CreateListsAndSharing < ActiveRecord::Migration[7.1]
  def change
    # Lists and List Restaurants
    create_table :lists do |t|
      t.string :name, null: false
      t.text :description
      t.references :owner, polymorphic: true, null: false
      t.integer :visibility, default: 0  # private: 0, shared: 1, public: 2
      t.boolean :premium, default: false
      t.integer :position
      
      t.timestamps
    end
    
    create_table :list_restaurants do |t|
      t.references :list, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.integer :position
      
      t.timestamps
    end
    
    # Sharing
    create_table :shares do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :shareable, polymorphic: true, null: false
      t.integer :permission, default: 0  # view: 0, edit: 1 (for lists only)
      t.integer :status, default: 0      # pending: 0, accepted: 1, rejected: 2
      
      t.timestamps
    end
    
    # Restaurant copies tracking
    create_table :restaurant_copies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.references :copied_restaurant, null: false, foreign_key: { to_table: :restaurants }
      
      t.timestamps
    end
    
    # Indexes
    add_index :lists, [:owner_type, :owner_id]
    add_index :list_restaurants, [:list_id, :restaurant_id], unique: true
    add_index :shares, [:creator_id, :recipient_id, :shareable_type, :shareable_id], 
              unique: true, 
              name: 'index_shares_uniqueness'
    add_index :restaurant_copies, [:user_id, :restaurant_id], unique: true
    
    # Add original_restaurant_id to restaurants for tracking copies
    add_column :restaurants, :original_restaurant_id, :bigint
    add_foreign_key :restaurants, :restaurants, column: :original_restaurant_id
    add_index :restaurants, :original_restaurant_id
  end
end