Rails.application.routes.draw do
  devise_for :users
  
  root to: "pages#home"

  resources :watch_lists do
    resources :watch_lists_coins, only: [:create, :update, :destroy]
  end

  resources :transactions

  resources :wallets do
    resources :wallets_coins, only: [:index, :show]
    resources :transactions
  end

  resources :transactions

  resources :coins, only: [:index, :show]
end
