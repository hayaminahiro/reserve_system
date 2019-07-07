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
  resources :users
end
