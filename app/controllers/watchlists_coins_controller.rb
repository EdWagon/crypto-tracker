class WatchlistsCoinsController < ApplicationController
  before_action :set_watchlist
  before_action :set_coin, only: [:destroy]


  def create
    @coin = Coin.find(params[:coin_id])
    @watchlist_coin = WatchlistsCoin.new(coin: @coin, watchlist: @watchlist)
    authorize @watchlist_coin.watchlist


    if @watchlist_coin.save
      redirect_to @watchlist, notice: 'Coin was successfully added to your watchlist.'
    else
      redirect_to @watchlist, alert: 'Failed to add coin to watchlist.'
    end
  end

  def destroy
    @watchlist_coin = WatchlistsCoin.find_by(watchlist: @watchlist, coin: @coin)
    authorize @watchlist

    if @watchlist_coin.destroy
      redirect_to @watchlist, notice: 'Coin was successfully removed from your watchlist.', status: :see_other
    else
      redirect_to @watchlist, alert: 'Failed to remove coin from watchlist.', status: :unprocessable_entity
    end
  end

  private
  def set_coin
    @coin = Coin.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to watchlists_path, alert: 'Coin not found.'
  end

  def set_watchlist
    @watchlist = Watchlist.find(params[:watchlist_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to watchlists_path, alert: 'Watchlist not found.'
  end
end
