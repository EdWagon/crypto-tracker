class UpdateAllPortfolioCompositionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    PortfolioComposition.recalculate_all
  end
end
