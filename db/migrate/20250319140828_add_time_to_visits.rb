class AddTimeToVisits < ActiveRecord::Migration[8.0]
  def up
    add_column :visits, :time_of_day, :time

    # Set default time (12:00) for existing visits
    Visit.update_all(time_of_day: Time.zone.local(2000, 1, 1, 12, 0, 0))

    # Make the column required after setting defaults
    change_column_null :visits, :time_of_day, false
  end

  def down
    remove_column :visits, :time_of_day
  end
end
