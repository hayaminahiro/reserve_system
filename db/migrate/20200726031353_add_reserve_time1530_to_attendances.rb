class AddReserveTime1530ToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time1530, :string
  end
end
