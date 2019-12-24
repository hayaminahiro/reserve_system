class AddTomorrowCheckAtToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :tomorrow_check_at, :boolean, default: false
  end
end
