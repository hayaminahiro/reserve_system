class AddOvertimeApprovalToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :overtime_approval, :integer, default: 1
  end
end
