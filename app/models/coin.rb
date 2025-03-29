class Coin < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_many :wallets, through: :wallets_coins
  has_many :transactions, dependent: :destroy

  include PgSearch::Model
  multisearchable against: [:name, :symbol]

  after_create_commit :rebuild_search_index
  after_update_commit :rebuild_search_index
  after_destroy_commit :rebuild_search_index

  # Overide the method to only retrive the transactions that belong to the user
  def transactions_by_user(user: nil)
    # Assuming you have a current_user method available
    # This will filter transactions to only those that belong to the current user
    transactions.where(user: user)
  end


  private

  def rebuild_search_index
    PgSearch::Multisearch.rebuild(Coin)
  end
end
