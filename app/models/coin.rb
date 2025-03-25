class Coin < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_many :wallets, through: :wallets_coins
  has_many :transactions, dependent: :destroy

end
