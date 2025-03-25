class WatchlistsController < ApplicationController
  before_action :set_watchlist, only: [ :show, :edit, :update, :destroy ]

  def index
    @watchlists = Watchlist.all
  end

  def show
    authorize @watchlist
  end

  def create
    @watchlist = Watchlist.new(watchlist_params)
    @watchlist.user = current_user
    if @watchlist.save
      redirect_to watchlists_path(@watchlist)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @watchlist.update(watchlist_params)
    redirect_to watchlists_path(@watchlist)
  end

  def destroy
    @watchlist.destroy

    redirect_to watchlists_path, status: :see_other
  end

  def new
    @watchlist = Watchlist.new
  end

  private

  def set_watchlist
    @watchlist = Watchlist.find(params[:id])
  end

  def watchlist_params
    params.require(:watchlist).permit(:name)
  end
end
