class AddNameToUser < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    # Copy names from profiles to users
    execute <<-SQL
      UPDATE users u
      SET first_name = p.first_name,
          last_name = p.last_name
      FROM profiles p
      WHERE u.id = p.user_id
    SQL
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
