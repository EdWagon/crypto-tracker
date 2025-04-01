class TransactionsController < ApplicationController
  before_action :set_transaction, only: [ :show, :edit, :update, :destroy ]
  before_action :skip_authorization, only: [ :create ]

  def index
    @transactions = policy_scope(Transaction)
  end

  def show
    authorize @transaction
  end

  def create
    to_coin_id = transaction_params[:to_coin_id]
    to_wallet_id = transaction_params[:to_wallet_id]
    to_quantity = transaction_params[:to_quantity].to_f
    new_transaction_params = transaction_params.to_h.symbolize_keys
    new_transaction_params.delete(:to_coin_id)
    new_transaction_params.delete(:to_wallet_id)
    new_transaction_params.delete(:to_quantity)
    new_transaction_params.merge!(user: current_user)
    new_transaction_params[:quantity] = new_transaction_params[:quantity].to_f
    new_transaction_params[:total_value] = new_transaction_params[:total_value].to_f

    case new_transaction_params[:transaction_type]
    when 'buy'
      ActiveRecord::Base.transaction do
        buy_transaction = Transaction.create!(new_transaction_params)
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
    when 'sell'
      ActiveRecord::Base.transaction do
        sell_transaction = Transaction.create!(new_transaction_params)
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
    when 'deposit'
      ActiveRecord::Base.transaction do
        deposit_transaction = Transaction.create!(new_transaction_params.merge(user: current_user))
        TradeTransaction.create!(
          transaction_type: "deposit",
          first_transaction: deposit_transaction,
          second_transaction: nil,
          third_transaction: nil
        )
      end
    when 'withdrawal'
      ActiveRecord::Base.transaction do
        withdrawal_transaction = Transaction.create!(new_transaction_params.merge(user: current_user))
        TradeTransaction.create!(
          transaction_type: "withdrawal",
          first_transaction: withdrawal_transaction,
          second_transaction: nil,
          third_transaction: nil
        )
      end
    when 'swap'
      buy_transaction = Transaction.new(new_transaction_params)
      buy_transaction.transaction_type = "buy"
      ActiveRecord::Base.transaction do
        buy_transaction.save!
        sell_transaction = Transaction.create!(
          user: current_user,
          date: buy_transaction.date,
          wallet: Wallet.find(to_wallet_id),
          coin: Coin.find(to_coin_id),
          transaction_type: 'sell',
          quantity: to_quantity,
          total_value: buy_transaction.total_value
        )
        TradeTransaction.create!(
          transaction_type: "swap",
          first_transaction: buy_transaction,
          second_transaction: sell_transaction,
          third_transaction: nil
        )
      end
    when 'transfer'
      ActiveRecord::Base.transaction do
        sending_transaction = Transaction.create!(new_transaction_params)
        receiving_transaction = Transaction.create!(
          user: current_user,
          date: sending_transaction.date,
          wallet: Wallet.find(to_wallet_id),
          coin: sending_transaction.coin,
          transaction_type: 'transfer',
          quantity: to_quantity
        )
        TradeTransaction.create!(
          transaction_type: "transfer",
          first_transaction: sending_transaction,
          second_transaction: receiving_transaction,
          third_transaction: nil
        )
      end

    else
      flash.now[:alert] = "Invalid transaction type"
      render :index, status: :unprocessable_entity and return
    end

    redirect_to transactions_path, notice: "Transaction successfully created"
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Transaction creation failed: #{e.message}"
    redirect_to transactions_path, status: :unprocessable_entity
  end


  def edit
    authorize @transaction
    render partial: "edit_modal", layout: false, locals:{transaction: @transaction}
  end

  def update
    # set the @transaction
    # trade_transaction = TradeTransaction.find_by(first_transaction_id: @transaction.id) || TradeTransaction.find_by(second_transaction_id: @transaction.id)
    # @other_transaction = trade_transaction.
    authorize @transaction
    @transaction.update(transaction_params)
    # @other_transaction.update(transaction_params)
    redirect_to transactions_path(@transaction)
  end

  def destroy
    authorize @transaction
    @transaction.destroy

    redirect_to transactions_path, status: :see_other
  end

  def new
    @transaction = Transaction.new
    @transaction.user = current_user
    authorize @transaction
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
end
