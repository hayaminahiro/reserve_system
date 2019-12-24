class AddTomorrowCheckOverToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :tomorrow_check_over, :boolean, default: false
  end
end
