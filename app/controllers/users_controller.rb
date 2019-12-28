class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, 
          :update_basic_info, :edit_personal_info, :update_personal_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  before_action :url_confirmation_show_page, only: :show
  before_action :url_confirmation_index_page, only: :index
  
  protect_from_forgery :except => [:import]
  
  def index
    @users = User.all
    @user = User.new
    # @users = User.paginate(page: params[:page]).search(params[:search])
    # @user = User.find_by(id: params[:id])
  end
  
  def import
    # fileはtmpに自動で一時保存される
    User.import(params[:file])
    flash[:success] = "ユーザー情報をCSVインポートしました！"
    redirect_to users_url
  end
  
  def edit_personal_info
  end
  
  def update_personal_info
    @users = User.all
    if @user.update_attributes(personal_info_params)
      flash[:success] = "#{@user.name}さんのユーザー情報を更新しました。"
      redirect_to action: 'index'
    else
      render :index
    end
  end
  
  def show
    @user = User.find(params[:id])
    # first_day: 値 ➡︎ 左のように、first_dayがキーになっている情報を受け取って@first_dayに代入
    # def first_day(date)
    #  !date.nil? ? Date.parse(date) : Date.current.beginning_of_month
    # end
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    @attendance = User.all.includes(:attendances)
    # 1ヶ月申請数
    @month_count = Attendance.where(superior_id: current_user).where(month_check: false).where.not(apply_month: nil).count
    # 勤怠変更申請
    @attendance_change_count = Attendance.where(superior_id_at: current_user).where(attendance_check: false).count
    # 残業申請
    @overtime_count = Attendance.where(superior_id_over: current_user).where(overtime_check: false).count
    # 1ヶ月申請と残業申請の@users
    @users = User.where(admin: false).where(superior: true).where.not(id: current_user.id)
    #勤怠ログで使用
    @users_all = User.all
    # 1ヶ月申請、自分以外の上長id
    #@users = User.where(admin: false).applied_superior(superior_id: current_user.id)
    # 残業申請、自分以外の上長id
    #@users_over = User.where(admin: false).applied_superior_over(superior_id_over: current_user.id)
    # 申請上長の名前
    @superior_a = User.find_by(id: 2).name #上長A
    @superior_b = User.find_by(id: 3).name #上長A
    @superior_c = User.find_by(id: 4).name #上長A
    #CSV出力
    respond_to do |format|
      format.html
      format.csv do
        #csv用の処理を書く
        send_data render_to_string, filename: "#{current_user.name} 勤怠情報 #{params[:first_day].to_date.strftime("%Y年%m月")}.csv", type: :csv
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザー新規作成に成功!"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render "edit"
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}を削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
      redirect_to @user
    else
      render "edit_basic_info"
    end
  end
  
  # 出勤中社員一覧
  def currently_working
    @working_users = User.all.includes(:attendances)
  end

  def work_log
    work_ids = current_user.works.ids
    if params[:value_year]
      date = Date.new(params[:value_year].to_i, params[:value_month].to_i)
      @logs = WorkLog.page(params[:page]).per(30)
                  .where(work_id: work_ids)
                  .where(day: date.beginning_of_month..date.end_of_month)
    else
      @logs = WorkLog.page(params[:page]).per(30).where(work_id: work_ids)
                  .where(day: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
    end
    # view_contextでpaginateメソッドを使いパーシャルの中身と同じものを生成
    paginator = view_context.paginate(
        @logs,
        remote: true
    )

    # render_to_stringでパーシャルの中身を生成
    logs = render_to_string(
        partial: 'table_work_log',
        locals: { logs: @logs }
    )
    if request.xhr?
      render json: {
          paginator: paginator,
          logs: logs,
          success: true # クライアント(js)側へsuccessを伝えるために付加
      }
    end
  end

  private
  
    def overwork_params
      params.permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, 
        :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_work_time, :work_time,
        :designated_work_start_time, :designated_work_end_time)
    end
    
    def personal_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, 
        :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    # beforeアクション
    def set_user
      @user = User.find(params[:id])
    end
    
    # ログイン済みのユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインして下さい。"
        redirect_to login_url
      end
    end
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    # showページ：他のユーザーのページをURL上で入力しても拒否
    def url_confirmation_show_page
      #@user = User.find(params[:id])
      unless current_user.admin? || current_user.superior?
        unless @user.id == @current_user.id
          flash[:danger] = "自分以外のユーザー情報の閲覧・編集はできません。"
          redirect_to root_url
        end
      end
    end

    # adminユーザー以外、URL直接入力してもindexページを開けない
    def url_confirmation_index_page
      unless current_user.admin?
        flash[:danger] = "一般ユーザーの閲覧はできません。"
        redirect_to root_url
      end
    end
end
