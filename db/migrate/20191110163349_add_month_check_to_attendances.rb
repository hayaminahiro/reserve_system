class AddMonthCheckToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :month_check, :boolean, default: false
  end
end
