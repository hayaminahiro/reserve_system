class Base < ApplicationRecord
  validates :base_number, length: { in: 1.. 10 }, presence: true
  validates :base_name, length: { in: 3.. 50 }, presence: true
  validates :attendance_type, presence: true
end
