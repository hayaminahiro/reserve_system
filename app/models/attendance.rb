class Attendance < ApplicationRecord
  # Attendanceモデルから見たuserモデルとの関連性は1対1
  belongs_to :user

  # 日付は必須
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出社時間が無ければ退社時間は無効
  validate :finished_at_is_invalid_without_started_at
  
  # 退社時間を保存する時、出社時間より早い時間の場合は無効
  #validate :invalid_started_at_is_faster_than_finished_at
  
  # 出社時間が無ければ退社時間は無効
  def finished_at_is_invalid_without_started_at
    errors.add(:started_at, "が必要です。") if started_at.blank? && finished_at.present?
  end
  
  # 退社時間を保存する時、出社時間より早い時間の場合は無効
  # started_at > finished_atになる事はまずない。
  # 理由は勤怠編集ページで扱うカラムはchange_〇〇。実際の出退勤ボタン押下時も上記条件になる事はまずない。
  # 翌日チェックの際に、勤怠編集モーダルからhidden_fieldで自動で値が送られる際に無駄に引っかかってしまう。
  #def invalid_started_at_is_faster_than_finished_at
  #  if started_at.present? && finished_at.present?
  #    errors.add(:started_at, "より早い退勤時刻は無効です。") if started_at > finished_at
  #  end
  #end

  # 1ヶ月勤怠申請
  enum month_approval: { "申請中" => 1, "承認" => 2, "否認" => 3, "なし" => 4 }, _suffix: true # 同じenum名定義できる
  # 勤怠変更申請
  enum attendance_approval: {"申請中" => 1, "承認" => 2, "否認" => 3, "なし" => 4}, _suffix: true
  # 残業申請
  enum overtime_approval: { "申請中" => 1, "承認" => 2, "否認" => 3, "なし" => 4}, _suffix: true
end

