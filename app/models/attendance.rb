class Attendance < ApplicationRecord
  belongs_to :user
  
  # 日付は必須
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出社時間が無ければ退社時間は無効
  validate :finished_at_is_invalid_without_started_at
  
  # 退社時間を保存する時、出社時間より早い時間の場合は無効
  validate :invalid_started_at_is_faster_than_finished_at
  
  # 出社時間が無ければ退社時間は無効
  def finished_at_is_invalid_without_started_at
    errors.add(:started_at, "が必要です。") if started_at.blank? && finished_at.present?
  end
  
  # 退社時間を保存する時、出社時間より早い時間の場合は無効
  def invalid_started_at_is_faster_than_finished_at
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時刻は無効です。") if started_at > finished_at
    end
  end
  
end
