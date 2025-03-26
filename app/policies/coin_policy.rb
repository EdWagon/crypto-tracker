class CoinPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      scope.all # If users can see all coins
      # scope.where(user: user) # If users can only see their coins
      # scope.where("name LIKE 't%'") # If users can only see coins starting with `t`
      # ...
    end
  end

  def show?
    true
  end

end
