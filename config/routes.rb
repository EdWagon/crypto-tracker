Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :watch_lists, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :watch_lists_coins, only: [:create, :update, :destroy]
  end

  resources :transactions, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  resources :wallets, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :wallets_coins, only: [:index, :show]
    resources :transactions, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  end

  resources :transactions, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  resources :coins, only: [:index, :show]
end
