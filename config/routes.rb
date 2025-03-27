Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"
  get "search", to: "search#index", as: :search


  get 'form', to: 'pages#form' # TODO: To be removed onces all formatting is done

  resources :watchlists do
    resources :watchlists_coins, only: [:create, :destroy]
  end

  resources :wallets do
    resources :wallets_coins, only: [:index, :show]
  end

  resources :transactions
  resources :coins, only: [:index, :show]
end
