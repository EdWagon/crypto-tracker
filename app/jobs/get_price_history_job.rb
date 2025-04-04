
require 'uri'
require 'net/http'
class GetPriceHistoryJob < ApplicationJob
  queue_as :default

  def perform( args = {})

    # coin = args[:coin]

    coin = Coin.find(args[:coin_id])
    # binding.break
    days = args[:days] || 365



    # Docs for the API: https://docs.coingecko.com/v3.0.1/reference/coins-id-market-chart
    # puts daysexit
    # binding.break

    url = URI("https://api.coingecko.com/api/v3/coins/#{coin.api_id}/market_chart?vs_currency=aud&days=#{days}&precision=full")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["x-cg-demo-api-key"] = ENV['COINGEKO_API_KEY']

    response = http.request(request)
    response = JSON.parse(response.read_body)

    # binding.break
    response["prices"].each_with_index do |pricearray, index|
      # binding.break
      datetime = Time.at(pricearray[0] / 1000.0).to_datetime
      price_value = pricearray[1]
      volume = response["total_volumes"][index][1]
      market_cap = response["market_caps"][index][1]



      price = Price.find_or_initialize_by(
        coin_id: coin.id,
        date: datetime
      )

      audcoin = Coin.find_by(symbol: "AUD")

      audprice = Price.find_or_initialize_by(
        coin_id: audcoin.id,
        date: datetime,
        price: 1
      )

      if audprice.new_record?
        audprice.save
        puts "Created AUD price for #{audcoin.name} (#{audcoin.symbol}) on #{datetime.strftime('%Y-%m-%d')}"
      end

      price.price = price_value
      price.market_cap = market_cap
      price.volume_24h = volume


      if price.new_record?
        action = "created"
      else
        action = "updated"
      end

      if price.save
        puts "Price #{action} for #{coin.name} (#{coin.symbol}) on #{datetime.strftime('%Y-%m-%d')}"
      else
        puts "Failed to save price for #{coin.name} (#{coin.symbol}) on #{datetime.strftime('%Y-%m-%d')}"
      end
      # binding.break
    end


  end
end
