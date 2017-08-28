Rails.application.routes.draw do
  root to: "high_voltage/pages#show", id: "home"

  apipie

  resources :meta 
  resources :statuses
  resources :contexts 
  resources :organizations do
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
  end


  get '/autocompletetags', to: 'images#autocomplete_tags', as: 'autocomplete_tags'

  resources :websites  do
    member do
      get :check_count
    end
  end

  scope "/organizations/:organization_id" do
    devise_for :users, :controllers => { registrations: 'registrations' }
  end

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
