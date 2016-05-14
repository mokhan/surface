Rails.application.routes.draw do
  root "sessions#new"
  resources :sessions, only: [:new, :create, :destroy]
  resources :registrations, only: [:new, :create]
  resources :training_sessions, only: [:index] do
    collection do
      post :upload
      post :drive_upload
    end
  end
  resources :programs, only: [:show]
  resources :profiles, only: [:new, :create, :show, :edit, :update], constraints: { id: /[^\/]+/ }
  resources :gyms, only: [:index, :show, :new, :create]
  get "/u/:id" => "profiles#show", constraints: { id: /[^\/]+/ }
  get "/dashboard" => "training_sessions#index", as: :dashboard
  get "/terms" => "static_pages#terms"

  get "/email/incoming", to: proc { [200, {}, ["OK"]] }
  post "/email/incoming" => "griddler/emails#create"
end
