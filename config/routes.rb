Rails.application.routes.draw do
  root to: "high_voltage/pages#show", id: "home"

  apipie

  resources :meta 
  resources :statuses

  resources :organizations do
    resources :users

    resources :images do
      get :toggle, on: :member

      collection do
        # FIXME: all of these need to be moved to their own resources/REST controllers, not using custom controller actions
        post :import
        get :export 
        post :titles
      end
    end

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

    resources :contexts 

    resources :websites  do
      member do
        get :check_count
      end
    end

    resources :invitations, only: %i[new create]
  end

  resources :images, only: %i[show] # so API can continue to use direct image URLs like /images/1.json

  scope "/organizations/:organization_id" do
    devise_for :users, skip: %i[registrations sessions passwords]
  end

  get '/autocompletetags', to: 'images#autocomplete_tags', as: 'autocomplete_tags'

  devise_for :users, only: %i[passwords sessions]
  resource :registration, only: %i[new update]

  get '/login',  to: redirect('/users/sign_in')
  get '/logout', to: redirect('/users/sign_out')

  if ENV["BOOKMARKLET"] == "true"
    match 'coyote' => 'coyote_consumer#iframe', via: [:get]
    match 'coyote_producer' => 'coyote_producer#index', via: [:get]
  end
end
