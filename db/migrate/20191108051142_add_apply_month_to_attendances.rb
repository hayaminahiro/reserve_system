class AddApplyMonthToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :apply_month, :datetime
  end
end
