class AddJobEndTimeToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :job_end_time, :datetime
  end
end
