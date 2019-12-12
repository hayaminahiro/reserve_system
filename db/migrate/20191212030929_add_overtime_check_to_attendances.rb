class AddOvertimeCheckToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :overtime_check, :boolean, default: false
  end
end
