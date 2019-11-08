class AddSuperiorIdToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :superior_id, :integer
  end
end
