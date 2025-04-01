class CoinsController < ApplicationController
  before_action :set_coin, only: [:show]

  def index
    @coins = Coin.all
  end

  def show
    # @coin.prices
    # raise
    # Select the latest Dayly prices for the coin

    current_time = Time.current

    @final_daily_prices = @coin.prices.select("DISTINCT ON (DATE(date)) *").order("DATE(date) DESC, date DESC")
    @hourly_prices = @coin.prices.where("date >= ?", current_time - 7.days)
      .select("DISTINCT ON (DATE(date), EXTRACT(HOUR FROM date)) *")
      .order(Arel.sql("DATE(date) DESC, EXTRACT(HOUR FROM date) DESC, date DESC"))
    @five_min_prices = @coin.prices.where("date >= ?", current_time - 24.hours)
      .select("DISTINCT ON (DATE(date), EXTRACT(HOUR FROM date), FLOOR(EXTRACT(MINUTE FROM date)/5)) *")
      .order(Arel.sql("DATE(date) DESC, EXTRACT(HOUR FROM date) DESC, FLOOR(EXTRACT(MINUTE FROM date)/5) DESC, date DESC"))


    if @final_daily_prices.size <= 365
      GetPriceHistoryJob.perform_later(@coin)
    end

    @transactions = policy_scope(Transaction) # This will filter the transactions to only those that belong to the current user
    @transactions = @transactions.where(coin: @coin) #_by_user(user: current_user) # TODO: Check with Ben if this is correct
    # authorize @transactions = @coin.transactions
    @message = Message.new
    authorize @message
    @wallets = policy_scope(Wallet) # This will filter the wallets to only those that belong to the current user
    @wallets = @wallets.where(coin: @coin) #_by_user(user: current_user) # TODO: Check with Ben if this is correct

  end

  private

  def set_coin
    @coin = Coin.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Coin not found"
    redirect_to coins_path
  end
end
