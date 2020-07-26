class AddReserveTime1100ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1100, :string
  end
end
