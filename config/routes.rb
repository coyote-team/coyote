Plate::Application.routes.draw do
  #root :to => "home#index"
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root :to => "pages#show", id: 'home'
end
