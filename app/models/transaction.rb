# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet
  belongs_to :coin

  has_many :trade_transactions_as_first, class_name: 'TradeTransaction', foreign_key: 'first_transaction_id', dependent: :destroy
  has_many :trade_transactions_as_second, class_name: 'TradeTransaction', foreign_key: 'second_transaction_id', dependent: :destroy
  has_many :trade_transactions_as_third, class_name: 'TradeTransaction', foreign_key: 'third_transaction_id', dependent: :destroy

  enum transaction_type: { buy: 'buy', sell: 'sell', swap: 'swap', transfer: 'transfer', deposit: 'deposit', withdrawal: 'withdrawal' }

  validates :transaction_type, presence: true
  validates :date, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }

  before_create :calculate_price_per_coin
  before_update :calculate_price_per_coin

  private

  def calculate_price_per_coin
    self.price_per_coin = self.total_value / self.quantity
  end
end
