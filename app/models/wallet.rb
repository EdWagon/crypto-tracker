class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallets_coins, dependent: :destroy
  has_many :coins, through: :wallets_coins
  has_many :transactions, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :wallet_type, presence: true, inclusion: { in: %w[exchange hardware software paper] }

  include PgSearch::Model
  multisearchable against: [:name, :wallet_address]

  after_create_commit :rebuild_search_index
  after_update_commit :rebuild_search_index
  after_destroy_commit :rebuild_search_index

  private

  def rebuild_search_index
    PgSearch::Multisearch.rebuild(Wallet)
  end
end
