# frozen_string_literal: true

# == Route Map
#
#                        Prefix Verb   URI Pattern                                                                              Controller#Action
#        apipie_apipie_checksum GET    /apidoc/apipie_checksum(.:format)                                                        apipie/apipies#apipie_checksum {:format=>/json/}
#                 apipie_apipie GET    /apidoc(/:version)(/:resource)(/:method)(.:format)                                       apipie/apipies#index {:version=>/[^\/]+/, :resource=>/[^\/]+/, :method=>/[^\/]+/}
#     create_many_api_resources POST   /api/v1/organizations/:organization_id/resources/create(.:format)                        api/resources#create_many
#             get_api_resources POST   /api/v1/organizations/:organization_id/resources/get(.:format)                           api/resources#index
#                 api_resources GET    /api/v1/organizations/:organization_id/resources(.:format)                               api/resources#index
#                               POST   /api/v1/organizations/:organization_id/resources(.:format)                               api/resources#create
#           api_resource_groups GET    /api/v1/organizations/:organization_id/resource_groups(.:format)                         api/resource_groups#index
#                               POST   /api/v1/organizations/:organization_id/resource_groups(.:format)                         api/resource_groups#create
#           api_representations GET    /api/v1/resources/:resource_id/representations(.:format)                                 api/representations#index
#                               POST   /api/v1/resources/:resource_id/representations(.:format)                                 api/representations#create
# api_canonical_representations GET    /api/v1/resources/canonical/:canonical_id/representations(.:format)                      api/representations#index {:canonical_id=>/.+/}
#                               POST   /api/v1/resources/canonical/:canonical_id/representations(.:format)                      api/representations#create {:canonical_id=>/.+/}
#        api_canonical_resource GET    /api/v1/resources/canonical/:canonical_id(.:format)                                      api/resources#show {:canonical_id=>/.+/}
#                               PATCH  /api/v1/resources/canonical/:canonical_id(.:format)                                      api/resources#update {:canonical_id=>/.+/}
#                               PUT    /api/v1/resources/canonical/:canonical_id(.:format)                                      api/resources#update {:canonical_id=>/.+/}
#                               DELETE /api/v1/resources/canonical/:canonical_id(.:format)                                      api/resources#destroy {:canonical_id=>/.+/}
#                  api_resource GET    /api/v1/resources/:id(.:format)                                                          api/resources#show
#                               PATCH  /api/v1/resources/:id(.:format)                                                          api/resources#update
#                               PUT    /api/v1/resources/:id(.:format)                                                          api/resources#update
#                               DELETE /api/v1/resources/:id(.:format)                                                          api/resources#destroy
#            api_resource_group GET    /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#show
#                               PATCH  /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#update
#                               PUT    /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#update
#                               DELETE /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#destroy
#            api_representation GET    /api/v1/representations/:id(.:format)                                                    api/representations#show
#                               DELETE /api/v1/representations/:id(.:format)                                                    api/representations#destroy
#                      api_user GET    /api/v1/profile(.:format)                                                                api/users#show
#                   new_session GET    /login(.:format)                                                                         sessions#new
#                         login POST   /login(.:format)                                                                         sessions#create
#               destroy_session GET    /logout(.:format)                                                                        sessions#destroy
#                        logout DELETE /logout(.:format)                                                                        sessions#destroy
#                     edit_user GET    /profile(.:format)                                                                       users#edit
#                       profile PUT    /profile(.:format)                                                                       users#update
#                      new_user GET    /register(.:format)                                                                      users#new
#                      register POST   /register(.:format)                                                                      users#create
#            new_password_reset GET    /login/forgot(.:format)                                                                  password_resets#new
#                  login_forgot POST   /login/forgot(.:format)                                                                  password_resets#create
#          sent_password_resets GET    /login/forgot/sent(.:format)                                                             password_resets#sent
#                password_reset GET    /login/forgot/:id(.:format)                                                              password_resets#show
#                               PATCH  /login/forgot/:id(.:format)                                                              password_resets#update
#                               PUT    /login/forgot/:id(.:format)                                                              password_resets#update
#            canonical_resource GET    /resources/canonical/:canonical_id(.:format)                                             resources#show {:canonical_id=>/.+/}
#           delete_organization GET    /organizations/:id/delete(.:format)                                                      organizations#delete
#                 organizations GET    /organizations(.:format)                                                                 organizations#index
#                               POST   /organizations(.:format)                                                                 organizations#create
#              new_organization GET    /organizations/new(.:format)                                                             organizations#new
#             edit_organization GET    /organizations/:id/edit(.:format)                                                        organizations#edit
#                  organization GET    /organizations/:id(.:format)                                                             organizations#show
#                               PATCH  /organizations/:id(.:format)                                                             organizations#update
#                               PUT    /organizations/:id(.:format)                                                             organizations#update
#                               DELETE /organizations/:id(.:format)                                                             organizations#destroy
#                     resources GET    /organizations/:organization_id/resources(.:format)                                      resources#index
#                               POST   /organizations/:organization_id/resources(.:format)                                      resources#create
#                  new_resource GET    /organizations/:organization_id/resources/new(.:format)                                  resources#new
#                 edit_resource GET    /organizations/:organization_id/resources/:id/edit(.:format)                             resources#edit
#                      resource GET    /organizations/:organization_id/resources/:id(.:format)                                  resources#show
#                               PATCH  /organizations/:organization_id/resources/:id(.:format)                                  resources#update
#                               PUT    /organizations/:organization_id/resources/:id(.:format)                                  resources#update
#                               DELETE /organizations/:organization_id/resources/:id(.:format)                                  resources#destroy
#        history_representation GET    /organizations/:organization_id/representations/:id/history(.:format)                    representations#history
#               representations GET    /organizations/:organization_id/representations(.:format)                                representations#index
#                               POST   /organizations/:organization_id/representations(.:format)                                representations#create
#            new_representation GET    /organizations/:organization_id/representations/new(.:format)                            representations#new
#           edit_representation GET    /organizations/:organization_id/representations/:id/edit(.:format)                       representations#edit
#                representation GET    /organizations/:organization_id/representations/:id(.:format)                            representations#show
#                               PATCH  /organizations/:organization_id/representations/:id(.:format)                            representations#update
#                               PUT    /organizations/:organization_id/representations/:id(.:format)                            representations#update
#                               DELETE /organizations/:organization_id/representations/:id(.:format)                            representations#destroy
#                resource_links GET    /organizations/:organization_id/resource_links(.:format)                                 resource_links#index
#                               POST   /organizations/:organization_id/resource_links(.:format)                                 resource_links#create
#             new_resource_link GET    /organizations/:organization_id/resource_links/new(.:format)                             resource_links#new
#            edit_resource_link GET    /organizations/:organization_id/resource_links/:id/edit(.:format)                        resource_links#edit
#                 resource_link GET    /organizations/:organization_id/resource_links/:id(.:format)                             resource_links#show
#                               PATCH  /organizations/:organization_id/resource_links/:id(.:format)                             resource_links#update
#                               PUT    /organizations/:organization_id/resource_links/:id(.:format)                             resource_links#update
#                               DELETE /organizations/:organization_id/resource_links/:id(.:format)                             resource_links#destroy
# representation_status_changes POST   /organizations/:organization_id/representation_status_changes(.:format)                  representation_status_changes#create
#        membership_assignments GET    /organizations/:organization_id/memberships/:membership_id/assignments(.:format)         assignments#index
#                   memberships GET    /organizations/:organization_id/memberships(.:format)                                    memberships#index
#               edit_membership GET    /organizations/:organization_id/memberships/:id/edit(.:format)                           memberships#edit
#                    membership GET    /organizations/:organization_id/memberships/:id(.:format)                                memberships#show
#                               PATCH  /organizations/:organization_id/memberships/:id(.:format)                                memberships#update
#                               PUT    /organizations/:organization_id/memberships/:id(.:format)                                memberships#update
#                               DELETE /organizations/:organization_id/memberships/:id(.:format)                                memberships#destroy
#                   assignments GET    /organizations/:organization_id/assignments(.:format)                                    assignments#index
#                               POST   /organizations/:organization_id/assignments(.:format)                                    assignments#create
#                new_assignment GET    /organizations/:organization_id/assignments/new(.:format)                                assignments#new
#                    assignment GET    /organizations/:organization_id/assignments/:id(.:format)                                assignments#show
#                               DELETE /organizations/:organization_id/assignments/:id(.:format)                                assignments#destroy
#               resource_groups GET    /organizations/:organization_id/resource_groups(.:format)                                resource_groups#index
#                               POST   /organizations/:organization_id/resource_groups(.:format)                                resource_groups#create
#            new_resource_group GET    /organizations/:organization_id/resource_groups/new(.:format)                            resource_groups#new
#           edit_resource_group GET    /organizations/:organization_id/resource_groups/:id/edit(.:format)                       resource_groups#edit
#                resource_group GET    /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#show
#                               PATCH  /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#update
#                               PUT    /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#update
#                               DELETE /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#destroy
#                          meta GET    /organizations/:organization_id/meta(.:format)                                           meta#index
#                               POST   /organizations/:organization_id/meta(.:format)                                           meta#create
#                     new_metum GET    /organizations/:organization_id/meta/new(.:format)                                       meta#new
#                    edit_metum GET    /organizations/:organization_id/meta/:id/edit(.:format)                                  meta#edit
#                         metum GET    /organizations/:organization_id/meta/:id(.:format)                                       meta#show
#                               PATCH  /organizations/:organization_id/meta/:id(.:format)                                       meta#update
#                               PUT    /organizations/:organization_id/meta/:id(.:format)                                       meta#update
#                               DELETE /organizations/:organization_id/meta/:id(.:format)                                       meta#destroy
#                   invitations POST   /organizations/:organization_id/memberships/invitations(.:format)                        invitations#create
#                new_invitation GET    /organizations/:organization_id/memberships/invitations/new(.:format)                    invitations#new
#                process_import POST   /organizations/:organization_id/imports/:id/process(.:format)                            imports#process
#                       imports GET    /organizations/:organization_id/imports(.:format)                                        imports#index
#                               POST   /organizations/:organization_id/imports(.:format)                                        imports#create
#                    new_import GET    /organizations/:organization_id/imports/new(.:format)                                    imports#new
#                   edit_import GET    /organizations/:organization_id/imports/:id/edit(.:format)                               imports#edit
#                        import GET    /organizations/:organization_id/imports/:id(.:format)                                    imports#show
#                               PATCH  /organizations/:organization_id/imports/:id(.:format)                                    imports#update
#                               PUT    /organizations/:organization_id/imports/:id(.:format)                                    imports#update
#                          user GET    /users/:id(.:format)                                                                     users#show
#                   staff_users GET    /staff/users(.:format)                                                                   staff/users#index
#               edit_staff_user GET    /staff/users/:id/edit(.:format)                                                          staff/users#edit
#                    staff_user GET    /staff/users/:id(.:format)                                                               staff/users#show
#                               PATCH  /staff/users/:id(.:format)                                                               staff/users#update
#                               PUT    /staff/users/:id(.:format)                                                               staff/users#update
#                               DELETE /staff/users/:id(.:format)                                                               staff/users#destroy
#         staff_password_resets POST   /staff/password_resets(.:format)                                                         staff/password_resets#create
#                       support GET    /support(.:format)                                                                       pages#support
#                          root GET    /                                                                                        pages#home
#               federal_offense        /deliveries                                                                              FederalOffense::Engine
#            rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#     rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#            rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#     update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#          rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#                   cloudtasker        /cloudtasker                                                                             Cloudtasker::Engine
#
# Routes for FederalOffense::Engine:
#      destroy_message POST /:id/destroy(.:format) federal_offense/messages#destroy
# destroy_all_messages POST /destroy_all(.:format) federal_offense/messages#destroy_all
#             messages GET  /                      federal_offense/messages#index
#              message GET  /:id(.:format)         federal_offense/messages#show
#
# Routes for Cloudtasker::Engine:
#    run POST /run(.:format) cloudtasker/worker#run

Rails.application.routes.draw do
  apipie
  ## API
  namespace :api do
    scope :v1 do
      scope "organizations/:organization_id" do
        resources :memberships, only: %i[create destroy index update]
        resources :meta, only: %i[index]
        resources :resources, only: %i[index create] do
          collection do
            post "create", as: :create_many, to: "resources#create_many"
            post :get, to: "resources#index"
          end
        end

        resources :resource_groups, only: %i[index create]
      end

      scope "resources/:resource_id" do
        resources :representations, only: %i[index create]
      end

      scope "resources/canonical/:canonical_id", constraints: {canonical_id: /.+/} do
        resources :representations, as: :canonical_representations, only: %i[index create]
      end

      resources :resources, as: :canonical_resources, path: "resources/canonical", only: %i[destroy show update], param: :canonical_id, constraints: {canonical_id: /.+/}
      resources :resources, only: %i[destroy show update]
      resources :resource_groups, only: %i[destroy show update]
      resources :representations, only: %i[show destroy]
      resource :user, only: %(show), path: "profile"
    end
  end

  ## Registration and sessions
  # Log in and out
  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy", as: :destroy_session
  delete "logout", to: "sessions#destroy"

  # Manage user profile
  get "profile", to: "users#edit", as: :edit_user
  put "profile", to: "users#update"

  # Sign up
  get "register", to: "users#new", as: :new_user
  post "register", to: "users#create"

  # Reset password
  get "login/forgot", to: "password_resets#new", as: :new_password_reset
  post "login/forgot", to: "password_resets#create"
  resources :password_resets, path: "login/forgot", only: %i[show update] do
    collection do
      get :sent
    end
  end

  ## Canonical resources - just redirects to the resource in the organization context
  resources :resources, as: :canonical_resources, path: "resources/canonical", only: %i[show], param: :canonical_id, constraints: {canonical_id: /.+/}

  ## Metadata
  resources :organizations do
    member do
      get :delete
    end
  end

  scope "organizations/:organization_id" do
    resources :resources

    resources :representations do
      member do
        get :history
      end
    end

    resources :resource_links
    resources :representation_status_changes, only: %i[create]

    resources :memberships, only: %i[index show edit update destroy] do
      resources :assignments, only: %i[index]
    end

    resources :assignments, only: %i[index show new create destroy]
    resources :resource_groups
    resources :meta
    resources :invitations, path: "memberships/invitations", only: %i[new create]
    resources :imports, except: %i[destroy] do
      member do
        post :process
      end
    end
  end

  resources :users, only: %i[show] # for viewing other user profiles

  ## Admin interface
  namespace :staff do
    resources :users, except: %i[new create]
    resource :password_resets, only: %i[create]
  end

  ## Bookmarklet
  if ENV["BOOKMARKLET"] == "true"
    get "coyote" => "coyote_consumer#iframe"
    get "coyote_producer" => "coyote_producer#index"
  end

  ## Scavenger hunt
  # mount ScavengerHunt::Engine, at: 'scavenger'

  ## Static pages
  get "support", to: "pages#support"
  root to: "pages#home"

  mount FederalOffense::Engine => "deliveries" if Rails.env.development? # This is the super important part
end
