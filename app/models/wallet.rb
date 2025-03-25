class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallets_coins, dependent: :destroy
  has_many :coins, through: :wallets_coins
  has_many :transactions, dependent: :destroy


  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :wallet_type, presence: true, inclusion: { in: %w[exchange hardware software paper] }
end
