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
    # debugger
  end
  
  def import
    # fileはtmpに自動で一時保存される
    User.import(params[:file])
    redirect_to users_url
  end
  
  def edit_personal_info
  end
  
  def update_personal_info
    @users = User.all
    if @user.update_attributes(personal_info_params)
      flash[:success] = "ユーザー情報を更新しました。"
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
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :department,
                            :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time,
        :designated_work_start_time, :designated_work_end_time)
    end
    
    def personal_info_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, 
        :password, :basic_time, :designated_work_start_time, :designated_work_end_time)
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
      if not current_user.admin?
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
