class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet
  belongs_to :coin

  enum transaction_type: { buy: 'buy', sell: 'sell', transfer_in: 'transfer_in', transfer_out: 'transfer_out' }

  validates :transaction_type, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :price_per_coin, numericality: { greater_than_or_equal_to: 0 }
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }
  validates :fee, numericality: { greater_than_or_equal_to: 0 }
end
