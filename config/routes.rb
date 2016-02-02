Rails.application.routes.draw do
  devise_for :users

  resources :site_urls
  resources :site_errors
  resources :sites

  root 'sites#index'
end
