class GetPriceHistoryJob < ApplicationJob
  queue_as :default

  def perform(coin)
    # Do something later


    url = URI("https://api.coingecko.com/api/v3/coins/#{coin.api_id}/market_chart?vs_currency=aud&days=365&interval=daily&precision=full")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["x-cg-demo-api-key"] = ENV['COINGEKO_API_KEY']

    response = http.request(request)
    response = JSON.parse(response.read_body)

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
