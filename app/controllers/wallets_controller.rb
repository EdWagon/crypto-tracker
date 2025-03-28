class WalletsController < ApplicationController
  before_action :set_wallet, only: [ :show, :edit, :update, :destroy ]

  def index
    @wallet = policy_scope(Wallet)
  end

  def show
    authorize @wallet
  end

  def new
    @wallet = Wallet.new
    @wallet.user = current_user
    authorize @wallet
  end

  def create
    @wallet = Wallet.new(wallet_params)
    @wallet.user = current_user
    authorize @wallet
    if @wallet.save
      redirect_to wallets_path(@wallet)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @wallet
  end

  def update
    authorize @wallet
    @wallet.update(wallet_params)
    redirect_to wallets_path(@wallet)
  end

  def destroy
    authorize @wallet
    @wallet.destroy

    redirect_to wallets_path, status: :see_other
  end



  private

  def set_wallet
    @wallet = Wallet.find(params[:id])
  end

  def wallet_params
    params.require(:wallet).permit(:name, :wallet_address, :wallet_type)
  end
end
