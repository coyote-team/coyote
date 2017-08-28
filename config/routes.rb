Rails.application.routes.draw do
  root to: "high_voltage/pages#show", id: "home"

  apipie

  resources :assignments do
    collection do
      post :bulk
    end
  end

  resources :descriptions do
    collection do
      post :bulk
    end
  end

  resources :meta 
  resources :statuses
  resources :contexts 
  resources :organizations

  get '/autocompletetags', to: 'images#autocomplete_tags', as: 'autocomplete_tags'

  resources :images do
    get :toggle, on: :member

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

  get '/login',  to: redirect('/users/sign_in')
  get '/logout', to: redirect('/users/sign_out')

  if ENV["BOOKMARKLET"] == "true"
    match 'coyote' => 'coyote_consumer#iframe', via: [:get]
    match 'coyote_producer' => 'coyote_producer#index', via: [:get]
  end
end
