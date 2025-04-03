class PortfolioCompositionsController < ApplicationController
  def index
    # get the portfolio composition for the user today using the policy scope
    # @portfolio_compositions = PortfolioComposition.where(user: current_user).where(date: Date.current)
    @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    if @portfolio_compositions.empty?
      PortfolioComposition.calculate_todays_user_portfolio(current_user)
      @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    end

    @portfolio_total = @portfolio_compositions.sum(:total_value)
    @portfolio_invested = @portfolio_compositions.sum(:amount_invested)
    @total_pnl = @portfolio_total - @portfolio_invested
  end

  def timeseries
    # Get the user's portfolio compositions
    @portfolio_compositions = policy_scope(PortfolioComposition).order(date: :asc)
    authorize @portfolio_compositions

    # Group and sum by date
    @investment_by_date = @portfolio_compositions
      .select('date, SUM(amount_invested) AS total_invested, SUM(total_value) AS total_value')
      .group(:date)
      .order(date: :desc)

    @time_series = @investment_by_date.to_a.map do |record|
      {
        date: record.date.to_time.to_i * 1000, # Convert to milliseconds for JavaScript
        total_invested: record.total_invested.to_f,
        total_value: record.total_value.to_f
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: @time_series }
    end
  end


  def composition
    @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    authorize @portfolio_compositions

    @composition = @portfolio_compositions.to_a.map do |composition|
      {
        coin: composition.coin.name,
        total_value: composition.total_value
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: @composition }
    end
  end

end
