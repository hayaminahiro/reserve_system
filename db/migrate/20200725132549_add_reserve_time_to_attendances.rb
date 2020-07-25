class AddReserveTimeToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_time, :string
  end
end
