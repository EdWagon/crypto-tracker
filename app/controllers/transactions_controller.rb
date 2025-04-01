class TransactionsController < ApplicationController
  before_action :set_transaction, only: [ :show, :destroy ]
  before_action :skip_authorization, only: [ :create ]

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

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :transaction_type,
      :date,
      :coin_id,
      :to_coin_id,
      :wallet_id,
      :to_wallet_id,
      :quantity,
      :to_quantity,
      :total_value,
      :fee
    )
  end

  def extract_transaction_params(params)
    data = params.to_h.symbolize_keys

    secondary_params = {
      to_coin_id: data.delete(:to_coin_id),
      to_wallet_id: data.delete(:to_wallet_id),
      to_quantity: data.delete(:to_quantity).to_f
    }

    data[:quantity] = data[:quantity].to_f
    data[:total_value] = data[:total_value].to_f if data[:total_value].present?

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
      buy_transaction = Transaction.create!(data[:primary])

      sell_transaction = Transaction.create!(
        user: current_user,
        date: buy_transaction.date,
        wallet: buy_transaction.wallet,
        coin: Coin.find_by(symbol: 'AUD'),
        transaction_type: 'sell',
        quantity: buy_transaction.total_value,
        total_value: buy_transaction.total_value
      )

      TradeTransaction.create!(
        transaction_type: "buy",
        first_transaction: buy_transaction,
        second_transaction: sell_transaction,
        third_transaction: nil
      )
    end
  end

  def process_sell_transaction(data)
    ActiveRecord::Base.transaction do
      sell_transaction = Transaction.create!(data[:primary])

      buy_transaction = Transaction.create!(
        user: current_user,
        date: sell_transaction.date,
        wallet: sell_transaction.wallet,
        coin: Coin.find_by(symbol: 'AUD'),
        transaction_type: 'buy',
        quantity: sell_transaction.total_value,
        total_value: sell_transaction.total_value
      )

      TradeTransaction.create!(
        transaction_type: "sell",
        first_transaction: sell_transaction,
        second_transaction: buy_transaction,
        third_transaction: nil
      )
    end
  end

  def process_deposit_transaction(data)
    ActiveRecord::Base.transaction do
      deposit_transaction = Transaction.create!(data[:primary])

      TradeTransaction.create!(
        transaction_type: "deposit",
        first_transaction: deposit_transaction,
        second_transaction: nil,
        third_transaction: nil
      )
    end
  end

  def process_withdrawal_transaction(data)
    ActiveRecord::Base.transaction do
      withdrawal_transaction = Transaction.create!(data[:primary])

      TradeTransaction.create!(
        transaction_type: "withdrawal",
        first_transaction: withdrawal_transaction,
        second_transaction: nil,
        third_transaction: nil
      )
    end
  end

  def process_swap_transaction(data)
    ActiveRecord::Base.transaction do
      buy_params = data[:primary].dup
      buy_params[:transaction_type] = "buy"
      buy_transaction = Transaction.create!(buy_params)

      sell_transaction = Transaction.create!(
        user: current_user,
        date: buy_transaction.date,
        wallet: Wallet.find(data[:secondary][:to_wallet_id]),
        coin: Coin.find(data[:secondary][:to_coin_id]),
        transaction_type: 'sell',
        quantity: data[:secondary][:to_quantity],
        total_value: buy_transaction.total_value
      )

      TradeTransaction.create!(
        transaction_type: "swap",
        first_transaction: buy_transaction,
        second_transaction: sell_transaction,
        third_transaction: nil
      )
    end
  end

  def process_transfer_transaction(data)
    ActiveRecord::Base.transaction do
      sending_transaction = Transaction.create!(data[:primary])

      receiving_transaction = Transaction.create!(
        user: current_user,
        date: sending_transaction.date,
        wallet: Wallet.find(data[:secondary][:to_wallet_id]),
        coin: sending_transaction.coin,
        transaction_type: 'transfer',
        quantity: data[:secondary][:to_quantity]
      )

      TradeTransaction.create!(
        transaction_type: "transfer",
        first_transaction: sending_transaction,
        second_transaction: receiving_transaction,
        third_transaction: nil
      )
    end
  end
end
