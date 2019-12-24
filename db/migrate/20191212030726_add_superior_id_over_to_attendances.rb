class AddSuperiorIdOverToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :superior_id_over, :integer
  end
end
