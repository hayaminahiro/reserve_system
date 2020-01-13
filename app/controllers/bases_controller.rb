class BasesController < ApplicationController
  before_action :url_confirmation_page, only: [:index, :new]

  def index
    @bases = Base.all
  end
  
  def show
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を登録しました。"
      redirect_to action: 'index'
    else
      render "new"
    end
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to action: 'index'
    else
      render "edit"
    end
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "拠点情報を削除しました。"
    redirect_to bases_url
  end

  private
  
    def base_params
      params.require(:base).permit(:base_number, :base_name, :attendance_type)
    end

    # beforeアクション

    # adminユーザー以外、URL直接入力してもページを開けない
    def url_confirmation_page
      unless current_user.admin?
        flash[:danger] = "一般ユーザーの閲覧はできません。"
        redirect_to root_url
      end
    end
  
end


