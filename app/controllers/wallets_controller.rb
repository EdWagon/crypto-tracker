class WalletsController < ApplicationController

  def index
    @wallets = policy_scope(Wallet)
  end

  def show
    authorize @wallets
  end
end
