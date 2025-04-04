class UpdatePortfolioCompositionForCoinDateJob < ApplicationJob
  queue_as :default

  def perform(user_id, coin_id, date)
    # Do something later
    PortfolioComposition.update_portfolio_for_coin_date(user_id, coin_id, date)
  end
end
