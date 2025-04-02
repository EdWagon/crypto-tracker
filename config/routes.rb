Rails.application.routes.draw do
  get 'prices/index'
  devise_for :users

  root to: "pages#home"

  get "search", to: "search#index", as: :search, defaults: { format: :json }
  get "search-coins", to: "search#coins", as: :search_coins, defaults: { format: :json }

  get 'elements', to: 'pages#elements' # TODO: To be removed onces all formatting is done

  resources :watchlists do
    resources :watchlists_coins, only: [:create, :update, :destroy]
  end

  resources :wallets do
    resources :wallets_coins, only: [:index, :show]
  end

  resources :transactions, except: [:edit, :update]

  resources :coins, only: [:index, :show] do
    resources :messages, only: :create
    resources :prices, only: :index
  end

  # This is the route for the admin dashboard
  # It is mounted at /jobs and is only accessible to admin users
  authenticate :user, ->(u) { u.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

end
