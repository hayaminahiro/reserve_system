module AttendancesHelper
  def current_time
    Time.new(
      Time.now.year,
      Time.now.month,
      Time.now.day,
      Time.now.hour,
      Time.now.min, 0
    )
  end
  
  # 在社時間を計算
  def working_times(started_at, finished_at)
    format("%.2f", (((finished_at - started_at) /60) / 60.0))
  end
  
  # 勤務時間の合計
  def working_times_sum(seconds)
    format("%.2f", seconds / 60 / 60.0)
  end
  
  # @first_dayの定義
  def first_day(date)
    !date.nil? ? Date.parse(date) : Date.current.beginning_of_month
  end

  # ユーザーに基づく1ヶ月間の値
  def user_attendances_month_date
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  # 不正な値があるか確認する
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:started_at].blank?
        attendances = false
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end
end



