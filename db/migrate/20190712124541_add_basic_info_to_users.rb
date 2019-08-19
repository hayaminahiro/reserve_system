class AddBasicInfoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :basic_time, :datetime, default: Time.zone.parse('2019-07-01 07:30:00')
    add_column :users, :work_time, :datetime, default: Time.zone.parse('2019-07-01 08:00:00')
  end
end

