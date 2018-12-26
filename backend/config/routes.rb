Rails.application.routes.draw do
  resources :registrations, only: [:create]
  resources :sessions, only: [:create]
  resource :profile, only: [:show, :update]
  resources :todos do
    collection do
      post :search
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
