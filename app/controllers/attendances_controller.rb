class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit, :update, :update_month]
  before_action :url_confirmation_attendances_edit_page, only: :edit
  
  def create
    # ルーティングを確認すると、/users/:user_id/attendances → paramsでuser_idを受け取る
    @user = User.find(params[:user_id])
    # @userモデルに紐付くattendanceモデルから、find_byで日付カラムがDate.todayを探して@attendanceに代入
    # @attendanceは、つまり今日を表す
    @attendance = @user.attendances.find_by(worked_on: Date.today)
    # もし今日（@attendance）がnilだったら
    if @attendance.started_at.nil?
      # current_time → 現在時刻を表す / attendance_helper.rb参照
      # @attendanceのstarted_atカラムを現在時刻として更新
      @attendance.update_attributes(started_at: current_time)
      flash[:info] = "おはようございます。"
      # started_atに値が存在していて、finished_atがnilだった場合
    elsif @attendance.finished_at.nil?
      # finished_atカラムを現在時刻として@attendanceを更新
      @attendance.update_attributes(finished_at: current_time)
      flash[:info] = "お疲れ様でした。"
    else
      flash[:danger] = "トラブルがあり登録できませんでした。"
    end
    redirect_to @user
  end
  
  def edit
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
    @dates = user_attendances_month_date
  end
  
  def update
    if attendances_invalid?
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
      flash[:success] = "勤怠情報を更新しました。"
      redirect_to user_url(@user, params:{first_day: params[:date]})
    else
      flash[:danger] = "不正な時間入力がありました。再入力して下さい。出社時間と退社時間はセットで入力されていますか？"
      redirect_to edit_attendances_path(@user, params[:date])
    end
  end

  # 申請ボタンから送信された情報（上長のidと申請月）を受け取って更新
  def update_month
    # 申請先上長が選択されているか確認するヘルパーメソッド
    if superior_present?
      update_month_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end

      flash[:success] = "所属長申請しました。"
      redirect_to @user
    end
  end





  def month_attendances_confirmation
    # 月の情報

    # @user = User.find(params[:id])
    # @attendances = Attendance.all
    # # (params[:day])で受け取ったデータを日付に変換し@dayに格納
    # @day = Date.parse(params[:day])
    # @attendance = @user.attendances.find_by(worked_on: @day)
  end

  def month_attendances_request_path
  end
  
  private
    def attendances_params
      # :attendancesがキーのハッシュの中にネストされたidと各カラムの値があるハッシュ
      # {"1" => {"started_at"=>"10:00", "finished_at"=>"18:00", "note"=>"シフトA"}
      params.permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    # 申請した上長idと申請月
    def update_month_params
      params.permit(attendances: [:superior_id, :apply_month])[:attendances]
    end
    
    # beforeアクション

    def set_user
      @user = User.find(params[:id])
    end
    
    def url_confirmation_attendances_edit_page
      @user = User.find(params[:id])
      @attendance = Attendance.find_by(params[:user_id])
      if not current_user.admin?
        unless @user.id == current_user.id
          flash[:danger] = "自分以外のユーザー情報の閲覧・編集はできません。"
          redirect_to root_url
        end
      end
    end
end
