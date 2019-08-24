class AddColumnScheduledEndTimeToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :scheduled_end_time, :datetime, default: Time.current.change(hour: 19, min: 0, sec: 0)
  end
end
