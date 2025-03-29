class WalletPolicy < ApplicationPolicy

  # Scope class for controlling access to collections of wallets
  # Used by the index action in the WalletsController
  class Scope < Scope
    # Returns only wallets that belong to the current user
    # This ensures users can only see their own wallets in list views
    def resolve
      scope.where(user: user)
    end
  end

  # Controls access to the show action in WalletsController
  # Determines if a user can view a specific wallet's details
  def show?
    # Only allows the wallet owner to view it
    record.user == user
  end

  # Controls access to the create action in WalletsController
  # Determines if a user can create a new wallet
  def create?
    # All authenticated users can create wallets
    true
  end

  # Controls access to the update action in WalletsController
  # Determines if a user can modify a wallet's details
  def update?
    # Only allows the wallet owner to make changes
    record.user == user
  end

  # Controls access to the destroy action in WalletsController
  # Determines if a user can delete a wallet
  def destroy?
    # Only allows the wallet owner to delete it
    record.user == user
  end

end
