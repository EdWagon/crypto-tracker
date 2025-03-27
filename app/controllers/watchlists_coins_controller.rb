class WatchlistsCoinsController < ApplicationController
  before_action :set_watchlist

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
    @watchlist_coin = WatchlistsCoin.find(params[:id])
    authorize @watchlist_coin.watchlist

    if @watchlist_coin.destroy
      redirect_to @watchlist, notice: 'Coin was successfully removed from your watchlist.', status: :see_other
    else
      redirect_to @watchlist, alert: 'Failed to remove coin from watchlist.', status: :unprocessable_entity
    end
  end

  private

  def set_watchlist
    @watchlist = Watchlist.find(params[:watchlist_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to watchlists_path, alert: 'Watchlist not found.'
  end
end
