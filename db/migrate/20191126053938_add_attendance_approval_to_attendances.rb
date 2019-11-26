class AddAttendanceApprovalToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :attendance_approval, :integer, default: 1
  end
end
