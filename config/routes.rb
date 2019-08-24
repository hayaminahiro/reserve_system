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
  
  # 残業申請
  get 'users/:id/attendances/:id/edit_overwork_request', to: 'users#edit_overwork_request', as: :edit_overwork_request
  patch 'users/:id/attendances/:id/update_overwork_request', to: 'users#update_overwork_request', as: :update_overwork_request
  
  # 残業申請受理
  get 'users/:id/attendances/:id/edit_overwork_receive', to: 'users#edit_overwork_receive', as: :edit_overwork_receive
  patch 'users/:id/attendances/:id/update_overwork_receive', to: 'users#update_overwork_receive', as: :update_overwork_receive
  
  resources :users do
    get 'currently_working', on: :collection
    member do
      # ユーザ情報の編集（indexページ）
      get 'edit_personal_info'
      patch 'update_personal_info'
    end
    resources :attendances
    # CSVルーティング
    collection { post :import }
  end
  
  # 拠点情報ルーティング
  resources :bases
end

