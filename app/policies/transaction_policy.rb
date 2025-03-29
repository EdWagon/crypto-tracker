class TransactionPolicy < ApplicationPolicy

  # User by the index method in the Transaction Policy
  # Only include transactions that are owned by the user
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  # Only the user who created the transaction can see it
  def show?
    record.user == user
  end


  def create?
    true
  end


  def update?
    record.user == user
  end


  def destroy?
    record.user == user
  end


end
