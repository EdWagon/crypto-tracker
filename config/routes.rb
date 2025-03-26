Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  resources :watchlists do
    resources :watchlists_coins, only: [:create, :update, :destroy]
  end

  resources :wallets do
    resources :wallets_coins, only: [:index, :show]
  end

  resources :transactions
  resources :coins, only: [:index, :show]
end
