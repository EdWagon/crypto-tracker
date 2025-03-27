class CoinsController < ApplicationController
  before_action :set_coin, only: [:show]

  def index
    @coins = policy_scope(Coin)
  end

  def show
    @transactions = policy_scope(Transaction)
    @transactions = @transactions.where(coin: @coin)
  end

  private

  def set_coin
    @coin = Coin.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Coin not found"
    redirect_to coins_path
  end
end
