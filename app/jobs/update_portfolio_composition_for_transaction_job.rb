class UpdatePortfolioCompositionForTransactionJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    PortfolioComposition.update_portfolio_for_transaction(transaction)
  end
end
