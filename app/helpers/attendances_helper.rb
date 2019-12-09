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

  # 翌日チェックのある在社時間を計算
  def tomorrow_check_working_times(change_started, change_finished)
    format("%.2f", (((change_finished - change_started) /60) / 60.0) + 24)
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
  
  # 不正な値があるか確認する・・・変更出勤時間と変更退勤時間
  def attendances_invalid?
    attendances = true #不正な値がない状態でスタート → true
    attendances_params.each do |id, item|
      # ①出勤時間と退勤h時間が空白の場合、nextで次の繰り返し処理が続行
      if item[:change_started].blank? && item[:change_finished].blank?
        next
      elsif item[:tomorrow_check] == "1"
        # raise
        next
      # ②出勤時間が空白、または退勤時間が空白の場合 → 繰り返し処理を終了しfalseを返す
      elsif item[:change_started].blank? || item[:change_finished].blank?
        attendances = false
        break
      # ③出勤時間が退勤時間より大きい場合 → 処理を終了しfalseを返す
      elsif item[:change_started] > item[:change_finished]
        attendances = false
        break
      end
    end
    # ①問題ないのでtrueを返す、②③問題ありfalseを返す
    attendances
  end

  # 1ヶ月申請「変更を送信する」ボタン：選択肢の確認
  def apply_and_checkbox_invalid?(ma, mc) # 引数：ma = item[:month_approval]、引数：mc = item[:month_check]
    # (承認or否認) かつ チェックボックスON ➡︎ 唯一trueの処理
    # mcはデバッガー確認時"0","1"でありtrue,falseではない。"◯"で文字列として扱う必要がある
    if (ma == "承認" || ma == "否認") and mc == "1" #and優先順位低い
      apply = true
    else # それ以外の処理は全てNG
      apply = false
    end
    apply
  end

  # 勤怠変更申請ボタン：選択肢の確認
  def attendance_change_invalid?(ap, check)
    # 指示者確認印が承認または否認 かつ 変更がONの時はtrue
    if (ap == "承認" || ap == "否認") and check == "1"
      apply = true
    else
      apply = false
    end
    apply
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
    superior
  end

  # 上長が選択されていればtrueを返す(上長だけ選択して申請できなくする)
  def attendance_superior_present?(superior_id_at, start, finish)
    if superior_id_at.present? && start.present? && finish.present?
      apply = true
    else
      apply = false
    end
    apply
  end
end






