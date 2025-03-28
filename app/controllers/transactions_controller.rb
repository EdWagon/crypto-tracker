class TransactionsController < ApplicationController
  before_action :set_transaction, only: [ :show, :edit, :update, :destroy ]

  def index
    @transactions = policy_scope(Transaction)
  end

  def show
    authorize @transaction
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user
    authorize @transaction
    if @transaction.save
      redirect_to transactions_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    authorize @transaction
    render partial: "edit_modal", layout: false, locals:{transaction: @transaction}
  end

  def update
    authorize @transaction
    @transaction.update(transaction_params)
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
      :wallet_id,
      :quantity,
      :price_per_coin,
      :total_value,
      :fee
    )
  end
end
