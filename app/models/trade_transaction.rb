# app/models/trade_transaction.rb
class TradeTransaction < ApplicationRecord
  belongs_to :first_transaction, class_name: 'Transaction', dependent: :destroy
  belongs_to :second_transaction, class_name: 'Transaction', optional: true, dependent: :destroy
  belongs_to :third_transaction, class_name: 'Transaction', optional: true, dependent: :destroy

  # before_destroy :destroy_associated_transactions

  validates :first_transaction, presence: true

  private

  # def destroy_associated_transactions
  #   Transaction.find(self.first_transaction.id).destroy
  #   Transaction.find(self.second_transaction.id).destroy
  #   Transaction.find(self.third_transaction.id).destroy
  # end
end
