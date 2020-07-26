class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit, :update, :update_month, :month_approval, :attendance_approval,
                                  :overtime_application, :update_approval, :update_applicability, :attendance_log,
                                  :update_overtime, :overtime_approval, :update_overtime_approval]
  before_action :url_attendances_edit, only: :edit
  before_action :url_admin_attendances_edit, only: :edit
  
  def create
    # ルーティングを確認すると、/users/:user_id/attendances → paramsでuser_idを受け取る
    @user = User.find(params[:user_id])
    # @userモデルに紐付くattendanceモデルから、find_byで日付カラムがDate.todayを探して@attendanceに代入
    # @attendanceは、つまり今日を表す
    @attendance = @user.attendances.find_by(worked_on: Date.today)
    # もし今日（@attendance）がnilだったら
    if @attendance.started_at.nil? && @attendance.change_started.nil?
      # current_time → 現在時刻を表す / attendance_helper.rb参照
      # @attendanceのstarted_atカラムを現在時刻として更新
      @attendance.update_attributes(started_at: current_time.floor_to(15.minutes))
      @attendance.update_attributes(change_started: current_time.floor_to(15.minutes))
      flash[:info] = "おはようございます。"
      # started_atに値が存在していて、finished_atがnilだった場合
    elsif @attendance.finished_at.nil? && @attendance.change_finished.nil?
      # finished_atカラムを現在時刻として@attendanceを更新
      @attendance.update_attributes(finished_at: current_time.floor_to(15.minutes))
      @attendance.update_attributes(change_finished: current_time.floor_to(15.minutes))
      flash[:info] = "お疲れ様でした。"
    else
      flash[:danger] = "トラブルがあり実行できませんでした。"
    end
    redirect_to @user
  end

  # 勤怠編集画面
  def edit
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
    @dates = user_attendances_month_date
    # 自分以外の上長
    @users = User.where(admin: false).where(superior: true).where.not(id: current_user.id)
  end

  # 勤怠情報update
  def update
    if attendances_invalid?
      attendances_params.each do |id, item|
        if attendance_superior_present?(item[:superior_id_at], item[:change_started], item[:change_finished])
          attendance = Attendance.find(id)
          attendance.update_attributes(item)
        end
      end
      flash[:success] = "勤怠情報を申請しました。申請できていない場合は必要項目が選択されているか確認して下さい。"
      redirect_to user_url(@user, params:{first_day: params[:date]})
    else
      flash[:danger] = "不正な時間入力がありました。出社時間と退社時間はセットで入力されているか確認して下さい。"
      redirect_to edit_attendances_path(@user, params[:date])
    end
  end

  # 勤怠変更申請表示モーダル
  def attendance_approval
    @start_time = params[:change_started]
    @users = User.applied_superior_at(superior_id_at: current_user.id)
    @first_day = first_day(params[:first_day]) # attendance_helper.rb参照
    @last_day = @first_day.end_of_month # end_od_monthは当月の終日を表す
    (@first_day..@last_day).each do |day| # 月の初日から終日までを表す
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date # 1ヶ月の情報を表す・・・attendances_helper.rb参照
  end

  # 勤怠変更申請の変更送信ボタンのアクション
  def update_applicability
    #「変更を送信する」ボタン：選択肢の確認(承認または否認、かつチェックON ➡︎ true)
    update_applicability_params.each do |id, item|
      if attendance_change_invalid?(item[:attendance_approval], item[:attendance_check]) # 処理がtrueになったら更新
        # eachで回ってきた該当するidのAttendanceオブジェクトをattendanceに代入
        attendance = Attendance.find(id)
        if item[:attendance_approval] == "否認"
          attendance.update_attributes(attendance_approval: "否認", attendance_check: "1")
        #elsif item[:attendance_approval] == "承認"
        #  attendance.update_attributes(attendance_approval: "承認", attendance_check: "1")
        else
          attendance.update_attributes!(item)
        end
      end
      #raise
    end
    flash[:success] = "勤怠変更申請返答しました。申請できていない場合は必要項目が選択されているか確認して下さい。"
    redirect_to user_path(@user)
  end

  # 勤怠ページから1ヶ月申請
  def update_month
    if superior_present? # params[:user][:apply_month] = @first_day /申請先上長が選択されているか確認
      update_month_params.each do |id, item| # idはAttendanceモデルオブジェクトのid、itemは各カラムの値が入った更新するための情報
        # 更新するべきAttendanceモデルオブジェクトを探してattendanceに代入
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
      flash[:success] = "所属長申請しました。"
      redirect_to @user
    else
      flash[:danger] = "申請先を選択して下さい。"
      redirect_to @user
    end
  end

  # 1ヶ月分勤怠申請/モーダル表示
  def month_approval
    @users = User.applied_superior(superior_id: current_user.id)
  end

  # 申請の承認可否の更新
  def update_approval
    # update_approval_paramsをeachで回す
    update_approval_params.each do |id, item|
      # もしapply_and_checkbox_invalid? ➡︎ 引数が(item[:month_approval], item[:month_check])の場合
      # each分の中にヘルパーメソッドを記入する事で毎回処理をチェックできる
      if apply_and_checkbox_invalid?(item[:month_approval], item[:month_check]) # 処理がtrueになったら更新
        # eachで回ってきた該当するidのAttendanceオブジェクトをattendanceに代入
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠申請しました。申請できていない場合は必要項目が選択されているか確認して下さい。"
    redirect_to user_path(@user)
  end

  # 勤怠変更申請ログ
  def attendance_log
    @users = User.all
    # 申請上長の名前
    @superior_a = User.find_by(id: 2).name #上長A
    @superior_b = User.find_by(id: 3).name #上長B
    @superior_c = User.find_by(id: 4).name #上長C
  end

  # 残業申請ボタン押下時モーダル表示
  def overtime_application
    @users = User.where(admin: false).applied_superior_over(superior_id_over: current_user.id)
    @attendance = Attendance.find(params[:id])
    @dates = user_attendances_month_date # 1ヶ月の情報を表す・・・attendances_helper.rb参照
    # showページから送られてくるdayキーに格納されている情報をparamsで受信
    @day = Date.parse(params[:day])
  end

  def update_overtime
    update_overtime_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes(item)
      if item[:reserve_check] == "true"
        flash[:success] = "予約確定しました。"
      else
        flash[:warning] = "予約キャンセルしました。"
      end
    end
    redirect_to user_path(@user)
  end

  def overtime_approval
    @users = User.all
  end

  def update_overtime_approval
    overtime_approval_params.each do |id, item|
      # each分の中にヘルパーメソッドを記入する事で毎回処理をチェックできる
      if overtime_approval_invalid?(item[:overtime_approval], item[:overtime_check])
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
    end
    flash[:success] = "残業申請返答しました。申請できていない場合は必要項目が選択されているか確認して下さい。"
    redirect_to user_path(@user)
  end


  private

    # 勤怠変更申請
    def attendances_params
      # :attendancesがキーのハッシュの中にネストされたidと各カラムの値があるハッシュ
      # {"1" => {"started_at"=>"10:00", "finished_at"=>"18:00", "note"=>"シフトA"}
      params.require(:user).permit(attendances: [:change_started, :change_finished, :note, :tomorrow_check, :superior_id_at,
                                  :attendance_approval, :attendance_check, :apply_month_at])[:attendances]
    end

    # 勤怠変更申請モーダル内カラム
    def update_applicability_params
      params.require(:user).permit(attendances: [:attendance_approval, :attendance_check, :started_at, :finished_at])[:attendances]
    end

    # 申請した上長idと申請月
    def update_month_params
      params.require(:user).permit(attendances: [:superior_id, :apply_month, :month_approval, :month_check])[:attendances]
    end

    # 申請の承認可否の更新
    def update_approval_params
      params.require(:user).permit(attendances: [:month_approval, :month_check])[:attendances]
    end

    # 残業申請カラム
    def update_overtime_params
      params.permit(attendances: [:reserve_time, :reserve_time1030, :reserve_time1100, :reserve_time1130, :reserve_time1400,
                                  :reserve_time1430, :reserve_time1500, :reserve_time1530, :reserve_check])[:attendances]
    end

    # 残業申請承認・否認の更新
    def overtime_approval_params
      params.require(:user).permit(attendances: [:overtime_approval, :overtime_check])[:attendances]
    end

    # beforeアクション

    def set_user
      @user = User.find(params[:id])
    end

    # 自分以外の勤怠編集ページへのアクセス拒否
    def url_attendances_edit
      unless @user.id == current_user.id
        redirect_to root_url
      end
    end

    # 管理者自身の編集ページへのアクセス拒否
    def url_admin_attendances_edit
      if current_user.admin?
        if @user.id == 1
          redirect_to root_url
        end
      end
    end

end
