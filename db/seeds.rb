require 'date'

require 'uri'
require 'net/http'


puts "Seeding database..."

# Clear existing data
# This is a destructive operation and should be used with caution in production environments.
# In a real-world scenario, you might want to use a more sophisticated approach to avoid data loss.
# For example, you could use a seed file to create test data without clearing the entire database.

# WARNING: This will delete all data in the specified tables!
# Use with caution in production environments!


puts "Clearing database..."
PortfolioComposition.destroy_all
Transaction.destroy_all
WalletsCoin.destroy_all
Wallet.destroy_all
Price.destroy_all
Coin.destroy_all
Watchlist.destroy_all
User.destroy_all

puts "Creating users..."

alice = User.create!(
  email: "alice@example.com",
  password: "alice@example.com",
  password_confirmation: "alice@example.com",
  first_name: "Alice",
  last_name: "Johnson",
  nickname: "Dora the Explorer",
  admin: true
  )
puts "Created user: #{alice.email}"

bob = User.create!(
  email: "bob@example.com",
  password: "bob@example.com",
  password_confirmation: "bob@example.com",
  first_name: "Bob",
  last_name: "Smith",
  nickname: "BuilderBob"
)
puts "Created user: #{bob.email}"

puts "Creating coins..."





# Get the top 10 coins by market Cap from CoinGecko
# You can increase this number to get more coins if needed (Note this only makes 1 call but is limited to 250 in one go)
coin_number = 100
url =  URI("https://api.coingecko.com/api/v3/coins/markets?vs_currency=aud&order=market_cap_desc&per_page=#{coin_number}&price_change_percentage=1y%2C30d%2C7d%2C24h%2C1h&locale=en&precision=full")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["accept"] = 'application/json'
request["x-cg-demo-api-key"] = ENV['COINGEKO_API_KEY']

response = http.request(request)
# puts response.read_body

response = JSON.parse(response.read_body)
response = response.map! { |coin| coin.deep_symbolize_keys!}

# binding.break

response.each do |coinhash|
  coin = Coin.new(
    name: coinhash[:name],
    symbol: coinhash[:symbol].upcase,
    api_id: coinhash[:id],
    logo_url: coinhash[:image])


  if coin.save!
    puts "Coin created: #{coin.name} (#{coin.symbol})"
  else
    puts "Failed to create coin: #{coin.name} (#{coin.symbol})"
  end

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
    puts "Price created for #{coin.name} (#{coin.symbol})"
  else
    puts "Failed to create price for #{coin.name} (#{coin.symbol})"
  end

end


bitcoin = Coin.find_by(api_id: "bitcoin")
ethereum = Coin.find_by(api_id: "ethereum")

australian_dollar = Coin.create!(
  name: "Australian Dollar",
  symbol: "AUD",
  api_id: nil,
  logo_url: "https://s2.coinmarketcap.com/static/cloud/img/fiat-flags/AUD.svg",
  website_url: "https://bitcoin.org"
)
puts "Created coin: #{australian_dollar.name} (#{australian_dollar.symbol})"

puts "Seeding price history..."

# Uncomment this to get the price history for all coins - note this is a call per coin
# Coin.all.each do |coin|

# if you uncomment the above line, comment this out
# Get the price history for Bitcoin and Ethereum only
[bitcoin, ethereum].each do |coin|

  GetPriceHistoryJob.perform_later(coin_id: coin.id, days: 365)

end


puts "Rebuilding search index"
PgSearch::Multisearch.rebuild(Coin)
PgSearch::Multisearch.rebuild(Wallet)
puts "Seeding completed!"


UpdateAllPortfolioCompositionJob.perform_later
