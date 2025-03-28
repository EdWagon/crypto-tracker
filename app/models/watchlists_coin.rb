class WatchlistsCoin < ApplicationRecord
  belongs_to :watchlist
  belongs_to :coin
end
