class AddSearchVectorToRestaurants < ActiveRecord::Migration[7.0]
  def up
    add_column :restaurants, :tsv, :tsvector
    execute <<-SQL
      CREATE INDEX restaurants_tsv_idx ON restaurants USING gin(tsv);
      
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON restaurants FOR EACH ROW EXECUTE FUNCTION
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', name, address
      );
    SQL

    # Existing records
    execute <<-SQL
      UPDATE restaurants SET tsv = 
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(address, '')), 'B');
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate ON restaurants;
      DROP INDEX restaurants_tsv_idx;
    SQL
    
    remove_column :restaurants, :tsv
  end
end
