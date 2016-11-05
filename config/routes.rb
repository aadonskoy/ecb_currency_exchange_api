Rails.application.routes.draw do
  resources :rates, only: :show
end
