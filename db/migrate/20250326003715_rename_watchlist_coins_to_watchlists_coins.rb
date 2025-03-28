class RenameWatchlistCoinsToWatchlistsCoins < ActiveRecord::Migration[7.1]
  def change
    rename_table :watchlist_coins, :watchlists_coins
  end
end
