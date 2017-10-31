
Rails.application.routes.draw do
  root to: "high_voltage/pages#show", id: "home"

  resources :organizations do
    resources :resources
    resources :representations
    resources :representation_status_changes, only: %i[create]
    resources :memberships, only: %i[index edit update destroy]
    resources :assignments
    resources :contexts 
    resources :meta, except: %i[destroy]
    resources :invitations, only: %i[new create]
  end

  resources :resource_links

  devise_for :users, 
    only: %i[passwords registrations sessions unlocks], 
    path: '/', 
    path_names: { 
      registration: 'profile'
    }

  resource :registration, only: %i[new update]
  resources :users, only: %i[show] # for viewing other user profiles

  constraints Coyote::AsApiRequest.new('v1') do
    scope :module => :api, :as => :api do
      scope 'organizations/:organization_id' do
        resources :resources, only: %i[index show create update]
        resources :representations, only: %i[index show create update]
      end
    end
  end

  namespace :staff do
    resources :users, except: %i[new create]
    resource :user_password_resets, only: %i[create]
  end

  get '/login',  to: redirect('/users/sign_in')
  get '/logout', to: redirect('/users/sign_out')

  if ENV["BOOKMARKLET"] == "true"
    match 'coyote' => 'coyote_consumer#iframe', via: [:get]
    match 'coyote_producer' => 'coyote_producer#index', via: [:get]
  end
end
