class AddReserveTime1130ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1130, :string
  end
end
