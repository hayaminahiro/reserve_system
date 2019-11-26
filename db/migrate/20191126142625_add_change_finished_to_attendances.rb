class AddChangeFinishedToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :change_finished, :datetime
  end
end
