class WatchlistPolicy < ApplicationPolicy
  # Scope class for controlling access to collections of watchlists
  # Used by the index action in the WatchlistsController
  class Scope < Scope
    # Returns only watchlists that belong to the current user
    # This ensures users can only see their own watchlists in list views
    def resolve
      scope.where(user: user)
    end
  end

  # Controls access to the show action in WatchlistsController
  # Determines if a user can view a specific watchlist's details
  def show?
    # Only allows the watchlist owner to view it
    record.user == user
  end

  # Controls access to the create action in WatchlistsController
  # Determines if a user can create a new watchlist
  def create?
    # All authenticated users can create watchlists
    # Note: Authentication should be handled at the controller level
    true
  end

  # Controls access to the update action in WatchlistsController
  # Determines if a user can modify a watchlist's details
  def update?
    # Only allows the watchlist owner to make changes
    record.user == user
  end

  # Controls access to the destroy action in WatchlistsController
  # Determines if a user can delete a watchlist
  def destroy?
    # Only allows the watchlist owner to delete it
    record.user == user
  end
end
