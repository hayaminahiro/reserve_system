class AddApplyMonthOverToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :apply_month_over, :datetime
  end
end
