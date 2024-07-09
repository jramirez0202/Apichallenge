Rails.application.routes.draw do
  root "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :pokemon, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
