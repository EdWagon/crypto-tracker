class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet
  belongs_to :coin

  enum transaction_type: { buy: 'buy', sell: 'sell', swap: 'swap', transfer: 'transfer' }

  validates :transaction_type, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :price_per_coin, numericality: { greater_than_or_equal_to: 0 }
  validates :fee, numericality: { greater_than_or_equal_to: 0 }

  before_create :calculate_total_value
  before_update :calculate_total_value

  private
  def calculate_total_value
    self.total_value = self.quantity * self.price_per_coin
  end

end
