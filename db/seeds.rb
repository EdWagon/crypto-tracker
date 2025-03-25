# db/seeds.rb

require 'date'

puts "Clearing database..."
User.destroy_all
Coin.destroy_all
Price.destroy_all

puts "Creating users..."

alice = User.create!(
  email: "alice@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Alice",
  last_name: "Johnson"
)
puts "Created user: #{alice.email}"

bob = User.create!(
  email: "bob@example.com",
  password: "securepass456",
  password_confirmation: "securepass456",
  first_name: "Bob",
  last_name: "Smith"
)
puts "Created user: #{bob.email}"

puts "Creating coins..."

bitcoin = Coin.create!(
  name: "Bitcoin",
  symbol: "BTC",
  api_id: "bitcoin",
  logo_url: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
  website_url: "https://bitcoin.org"
)
puts "Created coin: #{bitcoin.name} (#{bitcoin.symbol})"

ethereum = Coin.create!(
  name: "Ethereum",
  symbol: "ETH",
  api_id: "ethereum",
  logo_url: "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
  website_url: "https://ethereum.org"
)
puts "Created coin: #{ethereum.name} (#{ethereum.symbol})"

puts "Seeding price history..."

[bitcoin, ethereum].each do |coin|
  10.times do |i|
    date = DateTime.now - (i + 1)

    price = rand(coin.symbol == "BTC" ? 40000..70000 : 2500..5000)
    market_cap = price * rand(19000000..21000000)
    price_change_24h = rand(-500..500)
    price_change_percentage_24h = (price_change_24h / price * 100).round(2)
    volume_24h = rand(1_000_000_000..100_000_000_000)
    circulating_supply = rand(19000000..21000000)
    total_supply = circulating_supply + rand(0..100000)
    max_supply = 21000000
    all_time_high = coin.symbol == "BTC" ? 69000 : 4800
    all_time_high_date = coin.symbol == "BTC" ? DateTime.new(2021, 11, 10) : DateTime.new(2021, 11, 10)

    Price.create!(
      coin: coin,
      price: price,
      market_cap: market_cap,
      date: date,
      price_change_24h: price_change_24h,
      price_change_percentage_24h: price_change_percentage_24h,
      volume_24h: volume_24h,
      circulating_supply: circulating_supply,
      total_supply: total_supply,
      max_supply: max_supply,
      all_time_high: all_time_high,
      all_time_high_date: all_time_high_date
    )
    puts "Added price for #{coin.name} on #{date.strftime('%Y-%m-%d')}: $#{price}"
  end
end

puts "Seeding completed!"
