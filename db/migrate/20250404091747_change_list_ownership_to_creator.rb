class ChangeListOwnershipToCreator < ActiveRecord::Migration[8.0]
  def change
    change_table :lists do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      
      # Temporarily allow null for owner columns while we migrate
      change_column_null :lists, :owner_type, true
      change_column_null :lists, :owner_id, true
    end

    # Copy owner_id to creator_id where owner_type is 'User'
    execute <<-SQL
      UPDATE lists 
      SET creator_id = owner_id 
      WHERE owner_type = 'User'
    SQL

    # For lists owned by organizations, set creator to the first member of that organization
    execute <<-SQL
      UPDATE lists l
      SET creator_id = (
        SELECT m.user_id 
        FROM memberships m 
        WHERE m.organization_id = l.owner_id 
        AND l.owner_type = 'Organization' 
        LIMIT 1
      )
      WHERE l.owner_type = 'Organization'
    SQL

    remove_columns :lists, :owner_type, :owner_id
  end
end
