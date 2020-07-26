class AddReserveTime1430ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1430, :string
  end
end
