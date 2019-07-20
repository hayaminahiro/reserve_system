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
  
end



