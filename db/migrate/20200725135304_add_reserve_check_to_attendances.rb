class AddReserveCheckToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :reserve_check, :boolean
  end
end
