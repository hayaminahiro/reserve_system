class AddReserveTime1030ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1030, :string
  end
end
