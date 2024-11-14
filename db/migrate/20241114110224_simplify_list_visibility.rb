class SimplifyListVisibility < ActiveRecord::Migration[8.0]
  def up
    # First, ensure all restricted lists become private
    execute <<-SQL
      UPDATE lists 
      SET visibility = 0 
      WHERE visibility = 1
    SQL

    # Then, ensure all discoverable lists become public
    execute <<-SQL
      UPDATE lists 
      SET visibility = 1 
      WHERE visibility = 2
    SQL

    # Add reshareable to shares
    add_column :shares, :reshareable, :boolean, default: true, null: false
  end

  def down
    remove_column :shares, :reshareable
    # Note: We can't reliably restore the three-state visibility
  end
end