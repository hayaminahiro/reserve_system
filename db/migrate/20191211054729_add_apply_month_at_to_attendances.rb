class AddApplyMonthAtToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :apply_month_at, :datetime
  end
end
