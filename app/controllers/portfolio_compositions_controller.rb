class PortfolioCompositionsController < ApplicationController
  def index

    # get the portfolio composition for the user today using the policy scope
    # This will be used to display the portfolio composition for the user for todays date
    # @portfolio_compositions = PortfolioComposition.where(user: current_user)
    # @portfolio_compositions = PortfolioComposition.where(user: current_user).where(date: Date.current)

    @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    if @portfolio_compositions.empty?
      PortfolioComposition.calculate_todays_user_portfolio(current_user)
      # binding.break
      @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    end

    # This will be used to display the portfolio composition for the user for todays date
    # binding.break

    # @portfolio_composition = @portfolio_compositions.where(date: Date.current)

    # @portfolio_compositions = @portfolio_compositions.where(user: current_user)
    # @portfolio_compositions = @portfolio_compositions


  end
end
