class AddReserveTime1400ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1400, :string
  end
end
