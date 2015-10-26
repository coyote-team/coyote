Plate::Application.routes.draw do
  apipie
  resources :assignments do
    collection do
      post :bulk
    end
  end
  resources :descriptions 
  resources :meta 
  resources :statuses
  resources :groups 
  get '/autocompletetags', to: 'images#autocomplete_tags', as: 'autocomplete_tags'
  resources :images do
    collection do
      post :import
      get :export 
      post :titles
    end
  end
  resources :websites  do
    member do
      get :check_count
    end
  end
  devise_for :users, :controllers => { registrations: 'registrations' }
  scope "/admin" do
    resources :users
  end
  root :to => "home#index"
  get "/pages/*id" => 'pages#show', as: :page, format: false
  #root :to => "pages#show", id: 'home'
  get '/login',  to: redirect('/users/sign_in')
  get '/logout',  to: redirect('/users/sign_out')
  #
end
