class WatchlistsCoinPolicy < ApplicationPolicy
  def create?
    record.user == user
  end

end
