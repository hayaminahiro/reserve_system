class AddJobContentToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :job_content, :string
  end
end
