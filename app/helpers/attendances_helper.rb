module AttendancesHelper
  # 現在時刻を表す
  def current_time
    # Time.new(　=> 現在時刻でTimeオブジェクト生成
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
  # まず当日を取得するためDate.currentを使用
  # これにRailsのメソッドであるbeginning_of_monthを繋げることで当月の初日を取得することが可能
  # first_dayメソッドの引数であるdateがnil(空)でなかった場合はtrueとなりDate.parse(date)、
  # nilだった場合falseとなりDate.current.beginning_of_monthとなる
  # つまり前者はdateに引数があればparse(date)で、文字列による日付をDateオブジェクトに変換
  # 後者は現在の日付から計算して月の初めの日（1日）を表す
  def first_day(date)
    !date.nil? ? Date.parse(date) : Date.current.beginning_of_month
  end

  # ユーザーに基づく1ヶ月間の値
  # UserモデルとAttendanceモデルを1対多と関連付け → @user.attendances という記法
  # @first_day以上かつ@last_day以下をwhereで範囲指定 つまり１ヶ月の情報
  def user_attendances_month_date
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  # 不正な値があるか確認する
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end

  # 申請先上長が選択されているか確認
  def superior_present?
    superior = true
    update_month_params.each do |id, item|
      if item[:superior_id].blank? && [:apply_month].present?
        superior = false
      elsif item[:superior_id].present? && [:apply_month].present?
        superior = true
        break
      end
    end
    return superior
  end



end






