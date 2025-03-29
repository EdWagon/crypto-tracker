# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # DO NOT EDIT THESE METHODS
  # These are used as application wide defaults and act as a catch all to
  # prevent unauthorized access to any model.
  # If you want to allow access to a specific action on a specific model,
  # you can override the method in the specific policy class.
  # For example, if you want to allow access to the index action on the Transaction model,
  # you can create a TransactionPolicy class and override the index? method there.

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user: user)
    end

    private

    attr_reader :user, :scope
  end
end
