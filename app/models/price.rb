class Price < ApplicationRecord
  belongs_to :coin


  # def latest
  #   self.class.where(coin_id: coin_id).order(date: :desc).first
  # end

  def self.daily_history_exists?(coin_id)
    # exists?(coin_id: coin_id, date: date)
    coin = Coin.find(coin_id)

    price_history = coin.prices
      .where("date >= ?", Time.current - 1.year)
      .select("DISTINCT ON (DATE(date)) *")
      .order("DATE(date) DESC, date DESC")

    if price_history.size  < 365
      return false
    else
      return true# Check if there are any prices for the last year
    end
  end
end
