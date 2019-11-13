class AddMonthApprovalToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :month_approval, :integer, default: 1
  end
end
