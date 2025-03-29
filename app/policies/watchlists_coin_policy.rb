class WatchlistsCoinPolicy < ApplicationPolicy
  # Controls access to the create action in WatchlistsCoinsController
  # Determines if a user can add a coin to a watchlist
  def create?
    # Allow only if the user owns the associated watchlist
    # Access the user through the watchlist relationship
    record.watchlist.user == user
  end

  # Controls access to the destroy action in WatchlistsCoinsController
  # Determines if a user can remove a coin from their watchlist
  def destroy?
    # Allow only if the user owns the associated watchlist
    record.watchlist.user == user
  end
end
