class CoinsController < ApplicationController
  before_action :set_coin, only: [:show]

  def index
    @coins = Coin.all
  end

  def show
    @transactions = @coin.transactions #_by_user(user: current_user) # TODO: Check with Ben if this is correct
    @transactions = policy_scope(@transactions) # This will filter the transactions to only those that belong to the current user
    # authorize @transactions = @coin.transactions
    authorize @message = Message.new
  end

  private

  def set_coin
    @coin = Coin.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Coin not found"
    redirect_to coins_path
  end
end
