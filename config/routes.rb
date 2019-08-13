Rails.application.routes.draw do
  root 'static_pages#top'
 
  # サインアップ
  get '/signup',  to: 'users#new'
  post '/signup', to: 'users#create'
  
  # ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  
  # ログアウト
  delete '/logout', to: 'sessions#destroy'
  
  # 基本情報の編集
  get '/edit_basic_info/:id', to: 'users#edit_basic_info', as: :basic_info
  patch 'update_basic_info', to: 'users#update_basic_info'
  
  # 勤怠情報の編集
  get '/users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch '/users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances

  resources :users do
    member do
      # ユーザ情報の編集（indexページ）
      get 'edit_personal_info'
      patch 'update_personal_info'
    end
    resources :attendances, only: :create
  end
end

