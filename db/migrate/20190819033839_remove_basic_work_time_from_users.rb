class RemoveBasicWorkTimeFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :basic_work_time, :datetime
  end
end
