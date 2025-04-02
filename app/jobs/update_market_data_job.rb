require 'uri'
require 'net/http'

class UpdateMarketDataJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    #
    coinlist = Coin.all.to_a.map! do |coin|
      coin.api_id
    end
    coinlist = coinlist.join("%2C")

    url = URI("https://api.coingecko.com/api/v3/coins/markets?vs_currency=aud&ids=#{coinlist}&order=market_cap_desc&per_page=250&price_change_percentage=1y%2C30d%2C7d%2C24h%2C1h&locale=en&precision=full")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["x-cg-demo-api-key"] = ENV['COINGEKO_API_KEY']

    response = http.request(request)
    response = JSON.parse(response.read_body)
    response = response.map! { |coin| coin.deep_symbolize_keys!}

    # binding.break
    response.each do |coinhash|
      coin = Coin.find_by(api_id: coinhash[:id])
      if coin
        price = Price.new(
          coin_id: coin.id,
          price: coinhash[:current_price],
          market_cap: coinhash[:market_cap],
          date: coinhash[:last_updated].to_datetime,
          price_change_24h: coinhash[:price_change_24h],
          price_change_percentage_24h: coinhash[:price_change_percentage_24h],
          volume_24h: coinhash[:total_volume],
          circulating_supply: coinhash[:circulating_supply],
          total_supply: coinhash[:total_supply],
          max_supply: coinhash[:max_supply],
          all_time_high: coinhash[:ath],
          all_time_high_date: coinhash[:ath_date].to_datetime,
          market_cap_rank: coinhash[:market_cap_rank],
          high_24h: coinhash[:high_24h],
          low_24h: coinhash[:low_24h],
          market_cap_change_24h: coinhash[:market_cap_change_24h],
          market_cap_change_percentage_24h: coinhash[:market_cap_change_percentage_24h],
          all_time_high_change_percentage: coinhash[:ath_change_percentage],
          all_time_low: coinhash[:atl],
          all_time_low_change_percentage: coinhash[:atl_change_percentage],
          all_time_low_date: coinhash[:atl_date].to_datetime,
          price_change_percentage_1h_aud: coinhash[:price_change_percentage_1h_in_currency],
          price_change_percentage_24h_aud: coinhash[:price_change_percentage_24h_in_currency],
          price_change_percentage_7d_aud: coinhash[:price_change_percentage_7d_in_currency],
          price_change_percentage_30d_aud: coinhash[:price_change_percentage_30d_in_currency],
          price_change_percentage_1y_aud: coinhash[:price_change_percentage_1y_in_currency]
        )

        if price.save!
          puts "Price created for coin #{coin.name}"
        else
          puts "Failed to create price for coin #{coin.name}"
        end
      else
        puts "Coin not found for API ID #{coinhash[:id]}"
      end
    end
  end
end
