class Attendance < ApplicationRecord
  belongs_to :user
  
  # 日付は必須
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出社時間が無ければ退社時間は無効
  validate :finished_at_is_invalid_without_started_at
  
  # 出社時間が無ければ退社時間は無効
  def finished_at_is_invalid_without_started_at
    errors.add(:started_at, "が必要です。") if started_at.blank? && finished_at.present?
  end
end
