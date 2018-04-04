Rails.application.routes.draw do
  root "sale#index"

  resources :sale, only: [:create]
end
