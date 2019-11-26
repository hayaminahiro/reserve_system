class AddChangeStartedToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :change_started, :datetime
  end
end
