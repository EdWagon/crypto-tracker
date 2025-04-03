class PortfolioCompositionsController < ApplicationController
  def index

    # get the portfolio composition for the user today using the policy scope
    # @portfolio_compositions = PortfolioComposition.where(user: current_user).where(date: Date.current)

    @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    if @portfolio_compositions.empty?
      PortfolioComposition.calculate_todays_user_portfolio(current_user)
      # binding.break
      @portfolio_compositions = policy_scope(PortfolioComposition).where(date: Date.current)
    end

    total_portfolio = policy_scope(PortfolioComposition)
    start_date = total_portfolio.minimum(:date)
    end_date = Date.current

    @portfolio_performance_timeseries = []

    (start_date..end_date).each do |date|
      date = {date: date}
      # binding.break

      date[:amount_invested] = total_portfolio.where(date: date).sum(:amount_invested)
      puts date[:amount_invested]
      # binding.break
      @portfolio_performance_timeseries << date
    end


  end

  def time_series
    # Get the user's portfolio compositions
    @portfolio_compositions = policy_scope(PortfolioComposition).order(date: :asc)
    authorize @portfolio_compositions
    # @portfolio_compositions = current_user.portfolio_compositions.order(date: :asc)

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
    # authorise @time_series

    respond_to do |format|
      format.html
      format.json { render json: @time_series }
    end
  end

end
