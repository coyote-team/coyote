ScavengerHunt::Engine.routes.draw do
  root to: 'home#index'
  resources :locations, only: %w(index show) do
    resource :game, only: :new
  end

  resources :games, only: :show do
    member do
      get :finish
      get :finished
    end

    resources :clues, only: %w(index show) do
      resources :hints, only: %w(show)
      resource :answer, only: %w(create new) do
        collection do
          get :correct
          get :incorrect
        end
      end
    end
  end

  resource :player, except: %w(destroy)
  resources :survey_questions, path: "survey", only: %w(index) do
    collection do
      post :answer
    end
  end

  get "leaderboard", to: "leaderboard#index"
end
