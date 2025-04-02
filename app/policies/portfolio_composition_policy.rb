class PortfolioCompositionPolicy < ApplicationPolicy

  # User by the index method in the Transaction Policy
  # Only include transactions that are owned by the user
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

end
