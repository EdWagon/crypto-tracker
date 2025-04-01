class PricesController < ApplicationController
  def index
    @coin = Coin.find(params[:coin_id])

    if params[:range] == "1d"
      # Extracts 5-min prices for the last day
      @prices = @coin.prices
        .where("date >= ?", Time.current - 1.day)
        .select("DISTINCT ON (DATE(date), EXTRACT(HOUR FROM date), FLOOR(EXTRACT(MINUTE FROM date)/5)) *")
        .order(Arel.sql("DATE(date) DESC, EXTRACT(HOUR FROM date) DESC, FLOOR(EXTRACT(MINUTE FROM date)/5) DESC, date DESC"))
    elsif params[:range] == "1w"
      # Extracts hourly prices for the last week
      @prices = @coin.prices
      .where("date >= ?", Time.current - 1.week)
      .select("DISTINCT ON (DATE(date), EXTRACT(HOUR FROM date)) *")
      .order(Arel.sql("DATE(date) DESC, EXTRACT(HOUR FROM date) DESC, date DESC"))
    elsif params[:range] == "1m"
      # Extracts hourly prices for the last month
      @prices = @coin.prices
      .where("date >= ?", Time.current - 1.month)
      .select("DISTINCT ON (DATE(date), EXTRACT(HOUR FROM date)) *")
      .order(Arel.sql("DATE(date) DESC, EXTRACT(HOUR FROM date) DESC, date DESC"))
    elsif params[:range] == "1y"
      # Extracts daily prices for the last year
      @prices = @coin.prices
        .where("date >= ?", Time.current - 1.year)
        .select("DISTINCT ON (DATE(date)) *")
        .order("DATE(date) DESC, date DESC")
    elsif params[:range] == "all"
      @prices = @coin.prices
        .select("DISTINCT ON (DATE(date)) *")
        .order("DATE(date) DESC, date DESC")

    else
      @prices = @coin.prices.order(date: :desc).limit(100)
    end

    @price_data = @prices.to_a.map { |price| { date: price.date.to_i * 1000, price: price.price } }

    # return as json if the request is an ajax request
    respond_to do |format|
      format.html
      format.json { render json: @price_data }
      # binding.break
    end
  end
end
