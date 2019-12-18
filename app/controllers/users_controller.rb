class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, 
          :update_basic_info, :edit_personal_info, :update_personal_info, :edit_overwork_request,
          :update_overwork_request]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info,
          :update_basic_info, :edit_overwork_request, :update_overwork_request]
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
    # @overtime_count = Attendance.where(superior_id_over: current_user).where.not(job_end_time: nil).count
    @overtime_count = Attendance.where(superior_id_over: current_user).count
    # applied_superior(1ヶ月申請) ➡︎ 自分以外の上長id
    @users = User.where(admin: false).applied_superior(superior_id: current_user.id)
    # 申請上長の名前
    @superior_a = User.find_by(id: 2).name #上長A
    @superior_b = User.find_by(id: 3).name #上長A
    @superior_c = User.find_by(id: 4).name #上長A
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

  # 残業申請受理
  def edit_overwork_receive
  end
  def update_overwork_request
  end
  def update_overwork_receive
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
      @user = User.find(params[:id])
      if not current_user.admin? || current_user.superior?
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
