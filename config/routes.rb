# frozen_string_literal: true

# == Route Map
#
#                                     Prefix Verb   URI Pattern                                                                              Controller#Action
#                  create_many_api_resources POST   /api/v1/organizations/:organization_id/resources/create(.:format)                        api/resources#create_many
#                          get_api_resources POST   /api/v1/organizations/:organization_id/resources/get(.:format)                           api/resources#index
#                              api_resources GET    /api/v1/organizations/:organization_id/resources(.:format)                               api/resources#index
#                                            POST   /api/v1/organizations/:organization_id/resources(.:format)                               api/resources#create
#                        api_resource_groups GET    /api/v1/organizations/:organization_id/resource_groups(.:format)                         api/resource_groups#index
#                                            POST   /api/v1/organizations/:organization_id/resource_groups(.:format)                         api/resource_groups#create
#                        api_representations GET    /api/v1/resources/canonical/:canonical_id/representations(.:format)                      api/representations#index
#                                            POST   /api/v1/resources/canonical/:canonical_id/representations(.:format)                      api/representations#create
#                                            GET    /api/v1/resources/:resource_id/representations(.:format)                                 api/representations#index
#                                            POST   /api/v1/resources/:resource_id/representations(.:format)                                 api/representations#create
#                               api_resource GET    /api/v1/resources/:id(.:format)                                                          api/resources#show
#                                            PATCH  /api/v1/resources/:id(.:format)                                                          api/resources#update
#                                            PUT    /api/v1/resources/:id(.:format)                                                          api/resources#update
#                         api_resource_group GET    /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#show
#                                            PATCH  /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#update
#                                            PUT    /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#update
#                                            DELETE /api/v1/resource_groups/:id(.:format)                                                    api/resource_groups#destroy
#                         api_representation GET    /api/v1/representations/:id(.:format)                                                    api/representations#show
#                                            PATCH  /api/v1/representations/:id(.:format)                                                    api/representations#update
#                                            PUT    /api/v1/representations/:id(.:format)                                                    api/representations#update
#                                            DELETE /api/v1/representations/:id(.:format)                                                    api/representations#destroy
#                                   api_user GET    /api/v1/profile(.:format)                                                                api/users#show
#                              edit_resource GET    /resources/:id/edit(.:format)                                                            resources#edit
#                                   resource GET    /resources/:id(.:format)                                                                 resources#show
#                                            PATCH  /resources/:id(.:format)                                                                 resources#update
#                                            PUT    /resources/:id(.:format)                                                                 resources#update
#                                            DELETE /resources/:id(.:format)                                                                 resources#destroy
#                        edit_representation GET    /representations/:id/edit(.:format)                                                      representations#edit
#                             representation GET    /representations/:id(.:format)                                                           representations#show
#                                            PATCH  /representations/:id(.:format)                                                           representations#update
#                                            PUT    /representations/:id(.:format)                                                           representations#update
#                                            DELETE /representations/:id(.:format)                                                           representations#destroy
#                     organization_resources GET    /organizations/:organization_id/resources(.:format)                                      resources#index
#                                            POST   /organizations/:organization_id/resources(.:format)                                      resources#create
#                  new_organization_resource GET    /organizations/:organization_id/resources/new(.:format)                                  resources#new
#               organization_representations GET    /organizations/:organization_id/representations(.:format)                                representations#index
#                                            POST   /organizations/:organization_id/representations(.:format)                                representations#create
#            new_organization_representation GET    /organizations/:organization_id/representations/new(.:format)                            representations#new
# organization_representation_status_changes POST   /organizations/:organization_id/representation_status_changes(.:format)                  representation_status_changes#create
#                   organization_memberships GET    /organizations/:organization_id/memberships(.:format)                                    memberships#index
#               edit_organization_membership GET    /organizations/:organization_id/memberships/:id/edit(.:format)                           memberships#edit
#                    organization_membership GET    /organizations/:organization_id/memberships/:id(.:format)                                memberships#show
#                                            PATCH  /organizations/:organization_id/memberships/:id(.:format)                                memberships#update
#                                            PUT    /organizations/:organization_id/memberships/:id(.:format)                                memberships#update
#                                            DELETE /organizations/:organization_id/memberships/:id(.:format)                                memberships#destroy
#                   organization_assignments GET    /organizations/:organization_id/assignments(.:format)                                    assignments#index
#                                            POST   /organizations/:organization_id/assignments(.:format)                                    assignments#create
#                new_organization_assignment GET    /organizations/:organization_id/assignments/new(.:format)                                assignments#new
#                    organization_assignment GET    /organizations/:organization_id/assignments/:id(.:format)                                assignments#show
#                                            DELETE /organizations/:organization_id/assignments/:id(.:format)                                assignments#destroy
#               organization_resource_groups GET    /organizations/:organization_id/resource_groups(.:format)                                resource_groups#index
#                                            POST   /organizations/:organization_id/resource_groups(.:format)                                resource_groups#create
#            new_organization_resource_group GET    /organizations/:organization_id/resource_groups/new(.:format)                            resource_groups#new
#           edit_organization_resource_group GET    /organizations/:organization_id/resource_groups/:id/edit(.:format)                       resource_groups#edit
#                organization_resource_group GET    /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#show
#                                            PATCH  /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#update
#                                            PUT    /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#update
#                                            DELETE /organizations/:organization_id/resource_groups/:id(.:format)                            resource_groups#destroy
#                          organization_meta GET    /organizations/:organization_id/meta(.:format)                                           meta#index
#                                            POST   /organizations/:organization_id/meta(.:format)                                           meta#create
#                     new_organization_metum GET    /organizations/:organization_id/meta/new(.:format)                                       meta#new
#                    edit_organization_metum GET    /organizations/:organization_id/meta/:id/edit(.:format)                                  meta#edit
#                         organization_metum GET    /organizations/:organization_id/meta/:id(.:format)                                       meta#show
#                                            PATCH  /organizations/:organization_id/meta/:id(.:format)                                       meta#update
#                                            PUT    /organizations/:organization_id/meta/:id(.:format)                                       meta#update
#                   organization_invitations POST   /organizations/:organization_id/invitations(.:format)                                    invitations#create
#                new_organization_invitation GET    /organizations/:organization_id/invitations/new(.:format)                                invitations#new
#                              organizations GET    /organizations(.:format)                                                                 organizations#index
#                                            POST   /organizations(.:format)                                                                 organizations#create
#                           new_organization GET    /organizations/new(.:format)                                                             organizations#new
#                          edit_organization GET    /organizations/:id/edit(.:format)                                                        organizations#edit
#                               organization GET    /organizations/:id(.:format)                                                             organizations#show
#                                            PATCH  /organizations/:id(.:format)                                                             organizations#update
#                                            PUT    /organizations/:id(.:format)                                                             organizations#update
#                                            DELETE /organizations/:id(.:format)                                                             organizations#destroy
#                             resource_links GET    /resource_links(.:format)                                                                resource_links#index
#                                            POST   /resource_links(.:format)                                                                resource_links#create
#                          new_resource_link GET    /resource_links/new(.:format)                                                            resource_links#new
#                         edit_resource_link GET    /resource_links/:id/edit(.:format)                                                       resource_links#edit
#                              resource_link GET    /resource_links/:id(.:format)                                                            resource_links#show
#                                            PATCH  /resource_links/:id(.:format)                                                            resource_links#update
#                                            PUT    /resource_links/:id(.:format)                                                            resource_links#update
#                                            DELETE /resource_links/:id(.:format)                                                            resource_links#destroy
#                           new_user_session GET    /sign_in(.:format)                                                                       devise/sessions#new
#                               user_session POST   /sign_in(.:format)                                                                       devise/sessions#create
#                       destroy_user_session DELETE /sign_out(.:format)                                                                      devise/sessions#destroy
#                          new_user_password GET    /password/new(.:format)                                                                  devise/passwords#new
#                         edit_user_password GET    /password/edit(.:format)                                                                 devise/passwords#edit
#                              user_password PATCH  /password(.:format)                                                                      devise/passwords#update
#                                            PUT    /password(.:format)                                                                      devise/passwords#update
#                                            POST   /password(.:format)                                                                      devise/passwords#create
#                   cancel_user_registration GET    /profile/cancel(.:format)                                                                devise/registrations#cancel
#                      new_user_registration GET    /profile/sign_up(.:format)                                                               devise/registrations#new
#                     edit_user_registration GET    /profile/edit(.:format)                                                                  devise/registrations#edit
#                          user_registration PATCH  /profile(.:format)                                                                       devise/registrations#update
#                                            PUT    /profile(.:format)                                                                       devise/registrations#update
#                                            DELETE /profile(.:format)                                                                       devise/registrations#destroy
#                                            POST   /profile(.:format)                                                                       devise/registrations#create
#                            new_user_unlock GET    /unlock/new(.:format)                                                                    devise/unlocks#new
#                                user_unlock GET    /unlock(.:format)                                                                        devise/unlocks#show
#                                            POST   /unlock(.:format)                                                                        devise/unlocks#create
#                           new_registration GET    /registration/new(.:format)                                                              registrations#new
#                               registration PATCH  /registration(.:format)                                                                  registrations#update
#                                            PUT    /registration(.:format)                                                                  registrations#update
#                                       user GET    /users/:id(.:format)                                                                     users#show
#                                staff_users GET    /staff/users(.:format)                                                                   staff/users#index
#                            edit_staff_user GET    /staff/users/:id/edit(.:format)                                                          staff/users#edit
#                                 staff_user GET    /staff/users/:id(.:format)                                                               staff/users#show
#                                            PATCH  /staff/users/:id(.:format)                                                               staff/users#update
#                                            PUT    /staff/users/:id(.:format)                                                               staff/users#update
#                                            DELETE /staff/users/:id(.:format)                                                               staff/users#destroy
#                 staff_user_password_resets POST   /staff/user_password_resets(.:format)                                                    staff/user_password_resets#create
#                                    support GET    /support(.:format)                                                                       pages#support
#                                       root GET    /                                                                                        pages#home
#                         rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#                  rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                         rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#                  update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                       rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#                                cloudtasker        /cloudtasker                                                                             Cloudtasker::Engine
#
# Routes for Cloudtasker::Engine:
#    run POST /run(.:format) cloudtasker/worker#run

Rails.application.routes.draw do
  namespace :api do
    scope :v1 do
      scope "organizations/:organization_id" do
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

      scope "resources/canonical/:canonical_id" do
        resources :representations, as: :canonical_representations, only: %i[index create]
      end

      resources :resources, as: :canonical_resources, path: "resources/canonical", only: %i[show update], param: :canonical_id
      resources :resources, only: %i[show update]
      resources :resource_groups, only: %i[destroy show update]
      resources :representations, only: %i[show update destroy]
      resource :user, only: %(show), path: "profile"
    end
  end

  resources :resources, only: %i[show edit update destroy]
  resources :representations, only: %i[show edit update destroy]

  resources :organizations do
    resources :resources, only: %i[index new create]
    resources :representations, only: %i[index new create]
    resources :representation_status_changes, only: %i[create]
    resources :memberships, only: %i[index show edit update destroy]
    resources :assignments, only: %i[index show new create destroy]
    resources :resource_groups
    resources :meta, except: %i[destroy]
    resources :invitations, only: %i[new create]
  end

  resources :resource_links

  devise_for :users,
    only:       %i[passwords registrations sessions unlocks],
    path:       "/",
    path_names: {
      registration: "profile",
    }

  resource :registration, only: %i[new update]
  resources :users, only: %i[show] # for viewing other user profiles

  namespace :staff do
    resources :users, except: %i[new create]
    resource :user_password_resets, only: %i[create]
  end

  if ENV["BOOKMARKLET"] == "true"
    match "coyote" => "coyote_consumer#iframe", :via => [:get]
    match "coyote_producer" => "coyote_producer#index", :via => [:get]
  end

  # mount ScavengerHunt::Engine, at: 'scavenger'

  # Last but not least, static pages
  get "support", to: "pages#support"
  root to: "pages#home"
end
