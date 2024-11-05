class AddLocationToGoogleRestaurants < ActiveRecord::Migration[8.0]
  def up
    enable_extension :postgis unless extension_enabled?(:postgis)
    
    # Add the PostGIS column
    execute <<-SQL
      ALTER TABLE google_restaurants 
      ADD COLUMN location geometry(Point, 4326)
    SQL
    
    # Migrate existing data
    GoogleRestaurant.find_each do |gr|
      if gr.latitude.present? && gr.longitude.present?
        execute(<<-SQL)
          UPDATE google_restaurants 
          SET location = ST_SetSRID(ST_MakePoint(#{gr.longitude}, #{gr.latitude}), 4326)
          WHERE id = #{gr.id}
        SQL
      end
    end
    
    # Add spatial index for the location column
    execute <<-SQL
      CREATE INDEX index_google_restaurants_on_location ON google_restaurants USING gist(location);
    SQL
    
    # Add btree index for id (if not already exists)
    add_index :google_restaurants, :id unless index_exists?(:google_restaurants, :id)
  end

  def down
    execute "DROP INDEX IF EXISTS index_google_restaurants_on_location"
    execute "ALTER TABLE google_restaurants DROP COLUMN IF EXISTS location"
  end
end