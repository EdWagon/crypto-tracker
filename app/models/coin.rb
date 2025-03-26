class Coin < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_many :wallets, through: :wallets_coins
  has_many :transactions, dependent: :destroy

  include PgSearch::Model
  multisearchable against: [:name, :symbol]

  after_create_commit :rebuild_search_index
  after_update_commit :rebuild_search_index
  after_destroy_commit :rebuild_search_index

  private

  def rebuild_search_index
    PgSearch::Multisearch.rebuild(Coin)
  end
end
