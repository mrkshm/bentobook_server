class RemoveJtiFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_index :users, :jti if index_exists?(:users, :jti)
    remove_column :users, :jti, :string
  end
end
