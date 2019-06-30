Rails.application.routes.draw do
  get 'static_pages/top'
  root 'application#hello'
end
