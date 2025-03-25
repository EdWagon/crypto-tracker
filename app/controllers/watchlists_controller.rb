class WatchlistsController < ApplicationController
  before_action :set_watchlist, only: [ :show, :edit, :update, :destroy ]

  def index
    @watchlists = policy_scope(Watchlist)
  end

  def show
    authorize @watchlist
  end

  def create
    @watchlist = Watchlist.new(watchlist_params)
    @watchlist.user = current_user
    authorize @watchlist
    if @watchlist.save
      redirect_to watchlists_path(@watchlist)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @watchlist
  end

  def update
    authorize @watchlist
    @watchlist.update(watchlist_params)
    redirect_to watchlists_path(@watchlist)
  end

  def destroy
    authorize @watchlist
    @watchlist.destroy

    redirect_to watchlists_path, status: :see_other
  end

  def new
    @watchlist = Watchlist.new
    @watchlist.user = current_user
    authorize @watchlist
  end

  private

  def set_watchlist
    @watchlist = Watchlist.find(params[:id])
  end

  def watchlist_params
    params.require(:watchlist).permit(:name)
  end
end
