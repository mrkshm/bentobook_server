class DeleteAllCuisineTypes < ActiveRecord::Migration[8.0]
  def up
    execute("DELETE FROM cuisine_types")
  end

  def down
  end
end
