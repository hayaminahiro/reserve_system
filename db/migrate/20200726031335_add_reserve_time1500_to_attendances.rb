class AddReserveTime1500ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1500, :string
  end
end
