class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallets_coins, dependent: :destroy
  has_many :coins, through: :wallets_coins
  has_many :transactions, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :wallet_type, presence: true, inclusion: { in: %w[exchange hardware software paper] }

  include PgSearch::Model
  multisearchable against: [ :name, :wallet_address, :coin_name, :coin_symbol ]

  after_create_commit :rebuild_search_index
  after_update_commit :rebuild_search_index
  after_destroy_commit :rebuild_search_index

  # Returns the total quantity of a specific coin in this wallet
  def coin_quantity(coin_id)
    coin_transactions = transactions.where(coin_id: coin_id)

    total_quantity = 0

    coin_transactions.each do |tx|
      if tx.debit
        total_quantity -= tx.quantity
      else
        total_quantity += tx.quantity
      end
    end

    # Return zero if negative (shouldn't happen in normal operation)
    [total_quantity, 0].max
  end

  # Returns the amount invested in a specific coin in this wallet
  def coin_invested_amount(coin_id)
    coin_transactions = transactions.where(coin_id: coin_id).order(:date, :created_at)

    # Track running amounts
    cumulative_amount = 0.0
    amount_invested = 0.0

    coin_transactions.each do |tx|
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
          cumulative_amount -= tx.quantity
        end
      end
    end

    # Return zero if negative (shouldn't happen in normal operation)
    [amount_invested, 0].max
  end

  # Returns the current market value of a specific coin in this wallet
  def coin_current_value(coin_id)
    quantity = coin_quantity(coin_id)
    return 0 if quantity <= 0

    # Find the most recent price
    price_record = Price.where(coin_id: coin_id)
                        .order(date: :desc)
                        .first

    if price_record
      quantity * price_record.price
    else
      0 # No price data available
    end
  end

  # Returns the total value of all coins in this wallet
  def total_value
    total = 0

    # Get unique coin IDs in this wallet
    coin_ids = transactions.pluck(:coin_id).uniq

    coin_ids.each do |coin_id|
      total += coin_current_value(coin_id)
    end

    total
  end

  # Returns a hash of all coins with their quantities in this wallet
  def coin_balances
    result = {}

    # Get unique coin IDs in this wallet
    coin_ids = transactions.pluck(:coin_id).uniq

    coin_ids.each do |coin_id|
      quantity = coin_quantity(coin_id)
      # Only include coins with positive quantity
      if quantity > 0
        coin = Coin.find(coin_id)
        result[coin] = quantity
      end
    end

    result
  end

  # Returns complete statistics for a specific coin in this wallet
  def coin_stats(coin_id)
    quantity = coin_quantity(coin_id)

    return nil if quantity <= 0

    coin = Coin.find(coin_id)
    invested = coin_invested_amount(coin_id)
    current_value = coin_current_value(coin_id)
    profit_loss = current_value - invested
    profit_loss_percentage = invested > 0 ? (profit_loss / invested * 100) : 0

    # Find average cost basis
    cost_basis = quantity > 0 ? (invested / quantity) : 0

    # Find latest price
    latest_price = Price.where(coin_id: coin_id).order(date: :desc).first&.price || 0

    {
      coin: coin,
      quantity: quantity,
      invested_amount: invested,
      current_value: current_value,
      profit_loss: profit_loss,
      profit_loss_percentage: profit_loss_percentage,
      cost_basis: cost_basis,
      current_price: latest_price
    }
  end

  # Returns statistics for all coins in this wallet
  def wallet_stats
    result = []

    # Get unique coin IDs in this wallet
    coin_ids = transactions.pluck(:coin_id).uniq

    coin_ids.each do |coin_id|
      stats = coin_stats(coin_id)
      result << stats if stats
    end

    result
  end

  private

  def rebuild_search_index
    PgSearch::Multisearch.rebuild(Wallet)
  end

  def coin_name
    coins.pluck(:name).join(" ")
  end

  def coin_symbol
    coins.pluck(:symbol).join(" ")
  end
end
