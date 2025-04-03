class TransactionsController < ApplicationController
  before_action :set_transaction, only: [ :show, :destroy ]
  before_action :skip_authorization, only: [ :create ]
  before_action :validate_sufficient_balance, only: [ :create ], unless: -> { transaction_params[:transaction_type] == 'deposit' }

  def index
    @transactions = policy_scope(Transaction)
  end

  def new
    @transaction = Transaction.new
    @transaction.user = current_user
    authorize @transaction
  end

  def show
    authorize @transaction
  end

  def create
    transaction_data = extract_transaction_params(transaction_params)

    begin
      process_transaction(transaction_data)
      redirect_to transactions_path, notice: "Transaction successfully created"
    rescue => e
          flash[:alert] = "Transaction creation failed: #{e.message}"
          redirect_to transactions_path, status: :unprocessable_entity
      end
  end

  def destroy
    authorize @transaction
    @transaction.destroy
    redirect_to transactions_path, status: :see_other
  end

  private

  def validate_sufficient_balance
    transaction_type = transaction_params[:transaction_type]
    coin_name = transaction_params[:coin_name]
    quantity = transaction_params[:quantity].to_f
    total_value = transaction_params[:total_value].to_f
    wallet_id = transaction_params[:wallet_id]
    to_coin_name = transaction_params[:to_coin_name]

    case transaction_type
    when 'buy'
      # Check if user has enough AUD
      aud_coin = Coin.find_by(symbol: 'AUD')
      unless has_sufficient_balance?(aud_coin.id, wallet_id, total_value)
        flash[:alert] = "Insufficient AUD balance for this purchase"
        redirect_to transactions_path, status: :unprocessable_entity and return
      end
    when 'sell', 'withdrawal'
      # Check if user has enough of the coin to sell or withdraw
      coin_id = Coin.find_by(name: coin_name)&.id
      unless has_sufficient_balance?(coin_id, wallet_id, quantity)
        flash[:alert] = "Insufficient #{coin_name} balance for this transaction"
        redirect_to transactions_path, status: :unprocessable_entity and return
      end
    when 'swap'
      # Check if user has enough of the source coin to swap
      coin_id = Coin.find_by(name: to_coin_name)&.id
      to_wallet_id = transaction_params[:to_wallet_id]
      to_quantity = transaction_params[:to_quantity].to_f

      unless has_sufficient_balance?(coin_id, to_wallet_id, to_quantity)
        flash[:alert] = "Insufficient #{to_coin_name} balance for this swap"
        redirect_to transactions_path, status: :unprocessable_entity and return
      end
    when 'transfer'
      # Check if user has enough of the coin to transfer
      coin_id = Coin.find_by(name: coin_name)&.id
      unless has_sufficient_balance?(coin_id, wallet_id, quantity)
        flash[:alert] = "Insufficient #{coin_name} balance for this transfer"
        redirect_to transactions_path, status: :unprocessable_entity and return
      end
    end
  end

  def has_sufficient_balance?(coin_id, wallet_id, required_quantity)
    # Get all transactions for this coin in this wallet for this user
    transactions = Transaction.where(
      user_id: current_user.id,
      coin_id: coin_id,
      wallet_id: wallet_id
    )

    # Calculate current balance
    current_balance = 0
    transactions.each do |tx|
      if tx.debit
        current_balance -= tx.quantity
      else
        current_balance += tx.quantity
      end
    end

    # Return true if balance is sufficient
    current_balance >= required_quantity
  end

  def calculate_realized_profit(transaction)
    return unless ['sell', 'withdrawal'].include?(transaction.transaction_type) ||
                  (transaction.transaction_type == 'swap' && transaction.debit)

    # Get all previous transactions for this coin for this user, ordered by date
    previous_transactions = Transaction.where(
      user_id: transaction.user_id,
      coin_id: transaction.coin_id
    ).where('date <= ?', transaction.date)
      .order(:date, :created_at)

    # Calculate cumulative amount of coin before this transaction
    cumulative_amount_before = 0
    cumulative_investment_before = 0

    previous_transactions.each do |prev_tx|
      next if prev_tx.id == transaction.id # Skip the current transaction

      if prev_tx.debit
        cumulative_amount_before -= prev_tx.quantity
      else
        cumulative_amount_before += prev_tx.quantity
      end

      # Track cumulative investment amount
      if prev_tx.transaction_type == 'buy' ||
         (prev_tx.transaction_type == 'swap' && !prev_tx.debit) ||
         prev_tx.transaction_type == 'deposit'
        cumulative_investment_before += (prev_tx.total_value || 0)
      elsif prev_tx.transaction_type == 'sell' ||
            (prev_tx.transaction_type == 'swap' && prev_tx.debit) ||
            prev_tx.transaction_type == 'withdrawal'
        # Adjust investment based on portion of holdings sold
        if cumulative_amount_before + prev_tx.quantity > 0
          portion_sold = prev_tx.quantity / (cumulative_amount_before + prev_tx.quantity)
          cumulative_investment_before -= (cumulative_investment_before * portion_sold)
        end
      end
    end

    # Calculate cumulative investment after this transaction
    cumulative_investment_after = cumulative_investment_before

    if cumulative_amount_before > 0
      # If we're selling/withdrawing, adjust the investment proportionally
      portion_sold = transaction.quantity / cumulative_amount_before
      investment_reduction = cumulative_investment_before * portion_sold
      cumulative_investment_after -= investment_reduction
    end

    # Calculate realized profit
    # Value of the order + difference in cumulative investment
    realized_profit = transaction.total_value -
                      (cumulative_investment_before - cumulative_investment_after)

    transaction.update(realised_profit: realized_profit)
  end


  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :transaction_type,
      :date,
      :coin_name,
      :to_coin_name,
      :wallet_id,
      :to_wallet_id,
      :quantity,
      :to_quantity,
      :total_value,
    )
  end

  def extract_transaction_params(params)
    data = params.to_h.symbolize_keys

    secondary_params = {
      to_wallet_id: data.delete(:to_wallet_id),
      to_quantity: data.delete(:to_quantity).to_f,
      to_coin_id: Coin.find_by(name: data[:to_coin_name])&.id,
      to_coin_name: data.delete(:to_coin_name)
    }

    data[:quantity] = data[:quantity].to_f
    data[:total_value] = data[:total_value].to_f if data[:total_value].present?
    data[:coin_id] = Coin.find_by(name: data[:coin_name])&.id
    data.delete(:coin_name)

    data[:user] = current_user

    {
      primary: data,
      secondary: secondary_params
    }
  end

  def process_transaction(data)
    transaction_type = data[:primary][:transaction_type]

    case transaction_type
    when 'buy'
      process_buy_transaction(data)
    when 'sell'
      process_sell_transaction(data)
    when 'deposit'
      process_deposit_transaction(data)
    when 'withdrawal'
      process_withdrawal_transaction(data)
    when 'swap'
      process_swap_transaction(data)
    when 'transfer'
      process_transfer_transaction(data)
    else
      raise "Invalid transaction type: #{transaction_type}"
    end
  end

  def process_buy_transaction(data)
    ActiveRecord::Base.transaction do
      buy_transaction = Transaction.create!(data[:primary].merge(debit: false))

      sell_transaction = Transaction.create!(
        user: current_user,
        date: buy_transaction.date,
        wallet: buy_transaction.wallet,
        coin: Coin.find_by(symbol: 'AUD'),
        transaction_type: 'sell',
        quantity: buy_transaction.total_value,
        total_value: buy_transaction.total_value,
        debit: true
      )

      TradeTransaction.create!(
        transaction_type: "buy",
        first_transaction: buy_transaction,
        second_transaction: sell_transaction,
        third_transaction: nil
      )

      UpdatePortfolioCompositionForTransactionJob.perform_later(buy_transaction.id)
      UpdatePortfolioCompositionForTransactionJob.perform_later(sell_transaction.id)
    end
  end

  def process_sell_transaction(data)
    ActiveRecord::Base.transaction do
      sell_transaction = Transaction.create!(data[:primary].merge(debit: true))

      buy_transaction = Transaction.create!(
        user: current_user,
        date: sell_transaction.date,
        wallet: sell_transaction.wallet,
        coin: Coin.find_by(symbol: 'AUD'),
        transaction_type: 'buy',
        quantity: sell_transaction.total_value,
        total_value: sell_transaction.total_value,
        debit: false
      )

      TradeTransaction.create!(
        transaction_type: "sell",
        first_transaction: sell_transaction,
        second_transaction: buy_transaction,
        third_transaction: nil
      )

      # Calculate and store realized profit
      calculate_realized_profit(sell_transaction)

      UpdatePortfolioCompositionForTransactionJob.perform_later(buy_transaction.id)
      UpdatePortfolioCompositionForTransactionJob.perform_later(sell_transaction.id)

    end
  end

  def process_deposit_transaction(data)
    ActiveRecord::Base.transaction do
      deposit_transaction = Transaction.create!(data[:primary].merge(debit: false))

      TradeTransaction.create!(
        transaction_type: "deposit",
        first_transaction: deposit_transaction,
        second_transaction: nil,
        third_transaction: nil
      )

      UpdatePortfolioCompositionForTransactionJob.perform_later(deposit_transaction.id)
    end
  end

  def process_withdrawal_transaction(data)
    ActiveRecord::Base.transaction do
      withdrawal_transaction = Transaction.create!(data[:primary].merge(debit: true))

      TradeTransaction.create!(
        transaction_type: "withdrawal",
        first_transaction: withdrawal_transaction,
        second_transaction: nil,
        third_transaction: nil
      )

      # Calculate and store realized profit
      calculate_realized_profit(withdrawal_transaction)

      UpdatePortfolioCompositionForTransactionJob.perform_later(withdrawal_transaction.id)
    end
  end

  def process_swap_transaction(data)
    ActiveRecord::Base.transaction do
      buy_params = data[:primary].dup
      buy_params[:debit] = false # Fixed: Correctly setting debit flag
      buy_params[:transaction_type] = "buy"
      buy_transaction = Transaction.create!(buy_params)

      sell_transaction = Transaction.create!(
        user: current_user,
        date: buy_transaction.date,
        wallet: Wallet.find(data[:secondary][:to_wallet_id]),
        coin: Coin.find_by(name: data[:secondary][:to_coin_name]),
        transaction_type: 'sell',
        quantity: data[:secondary][:to_quantity],
        total_value: buy_transaction.total_value,
        debit: true
      )

      TradeTransaction.create!(
        transaction_type: "swap",
        first_transaction: buy_transaction,
        second_transaction: sell_transaction,
        third_transaction: nil
      )

      # Calculate and store realized profit for the sell side of the swap
      calculate_realized_profit(sell_transaction)

      UpdatePortfolioCompositionForTransactionJob.perform_later(buy_transaction.id)
      unless sell_transaction.coin_id == buy_transaction.coin_id
        UpdatePortfolioCompositionForTransactionJob.perform_later(sell_transaction.id)
      end
    end
  end

  def process_transfer_transaction(data)
    ActiveRecord::Base.transaction do
      sending_transaction = Transaction.create!(data[:primary].merge(debit: true))

      receiving_transaction = Transaction.create!(
        user: current_user,
        date: sending_transaction.date,
        wallet: Wallet.find(data[:secondary][:to_wallet_id]),
        coin: sending_transaction.coin,
        transaction_type: 'transfer',
        quantity: data[:secondary][:to_quantity],
        debit: false
      )

      TradeTransaction.create!(
        transaction_type: "transfer",
        first_transaction: sending_transaction,
        second_transaction: receiving_transaction,
        third_transaction: nil
      )
      # To prevent a race condition we only call this once as the coins are the same
      UpdatePortfolioCompositionForTransactionJob.perform_later(sending_transaction.id)
    end
  end
end
