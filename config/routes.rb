Plate::Application.routes.draw do
  resources :descriptions 
  resources :meta 
  resources :statuses
  resources :groups 
  resources :images do
    collection do
      post :import
      get :export 
    end
  end
  resources :websites 
  devise_for :users
  root :to => "home#index"
  get "/pages/*id" => 'pages#show', as: :page, format: false
  #root :to => "pages#show", id: 'home'
end
