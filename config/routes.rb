Plate::Application.routes.draw do
  resources :descriptions do
  end

  resources :meta do
  end

  resources :statuses do
  end

  resources :groups do
  end

  resources :images do
  end

  resources :websites do
  end

  resources :descriptions 
  resources :meta 
  resources :statuses
  resources :groups 
  resources :images 
  resources :websites 
  devise_for :users
  #root :to => "home#index"
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root :to => "pages#show", id: 'home'
end
