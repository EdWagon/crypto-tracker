class PortfolioComposition < ApplicationRecord
  belongs_to :user
  belongs_to :coin

  validates :date, presence: true
  validates :user_id, uniqueness: { scope: [:coin_id, :date], message: "should have only one portfolio composition per coin per day" }

  # Scopes for common queries
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_date, ->(date) { where(date: date) }
  scope :for_coin, ->(coin_id) { where(coin_id: coin_id) }
  scope :latest, -> { order(date: :desc) }

  # Calculate and update portfolio composition for a specific user, coin, and date
  def self.calculate_and_save(user_id, coin_id, date)
    user = User.find(user_id)
    coin = Coin.find(coin_id)

    # Find or initialize a new portfolio composition record
    portfolio = find_or_initialize_by(user_id: user_id, coin_id: coin_id, date: date)

    # Calculate cumulative amount
    portfolio.cumulative_amount = calculate_cumulative_amount(user_id, coin_id, date)

    # Calculate amount invested
    portfolio.amount_invested = calculate_amount_invested(user_id, coin_id, date)

    # Calculate total value
    current_price = get_current_price(coin_id, date)
    portfolio.total_value = portfolio.cumulative_amount * current_price if portfolio.cumulative_amount && current_price

    # Save the record
    portfolio.save
    portfolio
  end

  # Calculate cumulative amount of a coin for a user up to a specific date
  def self.calculate_cumulative_amount(user_id, coin_id, date)
    # Get all transactions for this user and coin up to the specified date
    transactions = Transaction.where(
      user_id: user_id,
      coin_id: coin_id,
      date: ...date.end_of_day
    )

    # Sum the quantities, considering debit/credit or transaction_type
    cumulative_amount = 0

    transactions.each do |transaction|
      # Add or subtract based on transaction type
      case transaction.transaction_type
      when 'buy', 'receive', 'mining', 'staking_reward'
        cumulative_amount += transaction.quantity.to_f
      when 'sell', 'send', 'fee'
        cumulative_amount -= transaction.quantity.to_f
      end
    end

    # Return the cumulative amount
    cumulative_amount
  end

  # Calculate total amount invested for a user's coin up to a specific date
  def self.calculate_amount_invested(user_id, coin_id, date)
    # Get buy transactions for this user and coin up to the specified date
    buy_transactions = Transaction.where(
      user_id: user_id,
      coin_id: coin_id,
      transaction_type: 'buy',
      date: ...date.end_of_day
    )

    # Get sell transactions for this user and coin up to the specified date
    sell_transactions = Transaction.where(
      user_id: user_id,
      coin_id: coin_id,
      transaction_type: 'sell',
      date: ...date.end_of_day
    )

    # Sum the total value of buy transactions
    total_buy_value = buy_transactions.sum(:total_value)

    # Sum the total value of sell transactions
    total_sell_value = sell_transactions.sum(:total_value)

    # Return the net investment (buys - sells)
    total_buy_value - total_sell_value
  end

  # Get the current price of a coin on a specific date
  def self.get_current_price(coin_id, date)
    # Try to find the price record for this coin and date
    price = Price.where(coin_id: coin_id, date: date.beginning_of_day..date.end_of_day)
                 .order(date: :desc)
                 .first

    # Return the price if found, otherwise nil
    price&.price
  end

  # Calculate and update all portfolio compositions for a specific date
  def self.calculate_for_date(date)
    # Get all users who have transactions
    user_ids = Transaction.where(date: ...date.end_of_day).distinct.pluck(:user_id)

    # Get all coins that have been transacted
    coin_ids = Transaction.where(date: ...date.end_of_day).distinct.pluck(:coin_id)

    # For each user and coin combination, calculate and save the portfolio composition
    user_ids.each do |user_id|
      coin_ids.each do |coin_id|
        calculate_and_save(user_id, coin_id, date)
      end
    end
  end

  # Calculate total portfolio value for a specific user and date
  def self.total_portfolio_value(user_id, date)
    for_user(user_id).for_date(date).sum(:total_value)
  end

  # Calculate total amount invested for a specific user and date
  def self.total_invested(user_id, date)
    for_user(user_id).for_date(date).sum(:amount_invested)
  end

  # Calculate profit/loss for a specific user and date
  def self.profit_loss(user_id, date)
    total_portfolio_value(user_id, date) - total_invested(user_id, date)
  end

  # Get the portfolio performance over time for a user
  def self.portfolio_performance(user_id, start_date, end_date)
    where(user_id: user_id, date: start_date..end_date)
      .group(:date)
      .select('date, SUM(total_value) as value, SUM(amount_invested) as invested')
      .order(:date)
  end

  # Get the portfolio composition (percentage of each coin) for a user on a specific date
  def self.composition_breakdown(user_id, date)
    compositions = for_user(user_id).for_date(date).includes(:coin)
    total_value = compositions.sum(:total_value)

    compositions.map do |comp|
      percentage = total_value > 0 ? (comp.total_value / total_value) * 100 : 0
      {
        coin: comp.coin.name,
        symbol: comp.coin.symbol,
        value: comp.total_value,
        percentage: percentage.round(2)
      }
    end
  end
end
