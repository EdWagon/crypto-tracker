class PortfolioComposition < ApplicationRecord
  belongs_to :user
  belongs_to :coin
  # has_many :wallets through: :wallets_coins

  validates :user_id, :coin_id, :date, presence: true
  validates :date, uniqueness: { scope: [:user_id, :coin_id] }






  # Class Methdods Used to Caclulate Portfolio Composition

  # Updates portfolio composition for a transaction
  # This method is used by the background job when a transaction is created or updated.
  # A Job is created using the Transaction model's after_create and after_update callbacks.
  # It updates the portfolio composition for the user and coin associated with the transaction
  # It also updates the portfolio composition for all dates between the Transction up to the current date
  def self.update_portfolio_for_transaction(transaction)
    # Get start date (earliest transaction date for this user and coin)
    start_date = transaction.date.to_date
    user_id = transaction.user_id
    coin_id = transaction.coin_id

    return unless start_date

    # Process each date in range from start_date till Toda
    (start_date..Date.current).each do |date|
      update_for_date(user_id, coin_id, date)
    end
  end





  # Updates portfolio composition for a specific user, coin, and date
  def self.update_for_date(user_id, coin_id, date)
    # Find or initialize portfolio composition record
    portfolio = find_or_initialize_by(user_id: user_id, coin_id: coin_id, date: date)

    audcoin = Coin.find_by(symbol: "AUD")

    audprice = Price.find_or_initialize_by(
      coin_id: audcoin.id,
      date: date.to_datetime,
      price: 1
    )

    if audprice.new_record?
      audprice.save
      puts "Created AUD price for #{audcoin.name} (#{audcoin.symbol}) on #{date.to_datetime.strftime('%Y-%m-%d')}"
    end



    # Calculate values
    cumulative_amount = calculate_cumulative_amount(user_id, coin_id, date)
    amount_invested = calculate_amount_invested(user_id, coin_id, date)
    total_value = calculate_total_value(coin_id, date, cumulative_amount)

    # Update record
    portfolio.update(
      cumulative_amount: cumulative_amount,
      amount_invested: amount_invested,
      total_value: total_value
    )
  end




  # Calculates how much of a coin the user owns at end of specified date
  def self.calculate_cumulative_amount(user_id, coin_id, date)
    transactions = Transaction.where(
      user_id: user_id,
      coin_id: coin_id
    ).where('date <= ?', date.end_of_day)

    cumulative_amount = 0.0

    transactions.each do |tx|
      if tx.debit
        cumulative_amount -= tx.quantity
      else
        cumulative_amount += tx.quantity
      end
    end

    cumulative_amount
  end

  # Calculates total amount invested in a coin up to specified date
  def self.calculate_amount_invested(user_id, coin_id, date)
    transactions = Transaction.where(
      user_id: user_id,
      coin_id: coin_id
    ).where('date <= ?', date.end_of_day)

    # Track running amounts
    cumulative_amount = 0.0
    amount_invested = 0.0

    transactions.order(:date, :created_at).each do |tx|
      if tx.transaction_type == 'buy' ||
         (tx.transaction_type == 'swap' && !tx.debit) ||
         tx.transaction_type == 'deposit'
        # Add to investment
        amount_invested += (tx.total_value || 0)
        cumulative_amount += tx.quantity
      elsif tx.transaction_type == 'sell' ||
            (tx.transaction_type == 'swap' && tx.debit) ||
            tx.transaction_type == 'withdrawal'
        # Remove proportional investment
        if cumulative_amount > 0
          portion_sold = tx.quantity / cumulative_amount
          amount_invested -= (amount_invested * portion_sold)
        end
        cumulative_amount -= tx.quantity
      end
    end

    amount_invested
  end

  # Gets current value based on price for the date
  def self.calculate_total_value(coin_id, date, cumulative_amount)
    return 0 if cumulative_amount <= 0

    # Find the closest price to the given date
    price_record = Price.where(coin_id: coin_id)
                        .where('date <= ?', date.end_of_day)
                        .order(date: :desc)
                        .first

    if price_record
      cumulative_amount * price_record.price
    else
      0 # No price data available
    end
  end

  # Recalculates portfolio for a specific user for today
  def self.calculate_todays_user_portfolio(user)
    Coin.find_each do |coin|
      earliest_date = Transaction.where(user_id: user.id, coin_id: coin.id)
          .minimum('date')&.to_date
      latest_date = Transaction.where(user_id: user.id, coin_id: coin.id)
          .maximum('date')&.to_date
      # binding.break
      # Skip if no transactions exist
      next unless earliest_date && latest_date
        update_for_date(user.id, coin.id, Date.current)
      end
  end


  # Recalculates portfolio for all users, coins, and dates
  def self.recalculate_all
    User.find_each do |user|
      Coin.find_each do |coin|
        # Find the earliest and latest transaction dates for this user and coin
        earliest_date = Transaction.where(user_id: user.id, coin_id: coin.id)
                                 .minimum('date')&.to_date
        latest_date = Transaction.where(user_id: user.id, coin_id: coin.id)
                               .maximum('date')&.to_date
        # binding.break
        # Skip if no transactions exist
        next unless earliest_date && latest_date

        # Update from earliest date to latest date
        (earliest_date..Date.current).each do |date|
          update_for_date(user.id, coin.id, date)
        end
      end
    end
  end

  # Gets the entire portfolio for a specific date
  def self.portfolio_on_date(user_id, date = Date.today)
    where(user_id: user_id, date: date)
      .includes(:coin)
      .where('cumulative_amount > 0')
  end

  # Backdates portfolio calculations for a user
  def self.backdate_for_user(user_id, days = 30)
    end_date = Date.today
    start_date = end_date - days.days

    # Get all coins the user has transacted
    coin_ids = Transaction.where(user_id: user_id)
                         .pluck(:coin_id).uniq

    coin_ids.each do |coin_id|
      # Find the earliest transaction date for this coin
      earliest_date = Transaction.where(user_id: user_id, coin_id: coin_id)
                              .minimum('date')&.to_date

      next unless earliest_date

      # Use the later of start_date or earliest_date as our actual start
      actual_start = [start_date, earliest_date].max

      # Update for each date from actual_start to end_date
      (actual_start..end_date).each do |date|
        update_for_date(user_id, coin_id, date)
      end
    end
  end
end
