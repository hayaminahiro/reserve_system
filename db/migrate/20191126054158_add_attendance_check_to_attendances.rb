class AddAttendanceCheckToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :attendance_check, :boolean, default: false
  end
end
