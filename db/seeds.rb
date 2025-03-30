require 'date'

puts "Clearing database..."
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
  password: "password123",
  password_confirmation: "password123",
  first_name: "Alice",
  last_name: "Johnson",
  nickname: "Dora the Explorer"
  )
puts "Created user: #{alice.email}"

bob = User.create!(
  email: "bob@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Bob",
  last_name: "Smith",
  nickname: "BuilderBob"
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
      coin_id: coin.id,
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


puts "Creating wallets..."

alice_wallet_1 = Wallet.create!(
  user_id: alice.id,
  name: "Alice's Exchange Wallet",
  wallet_address: "1A2B3C4D5E6F7G8H9I0J",
  wallet_type: "exchange"
)
puts "Created wallet for Alice: #{alice_wallet_1.name}"

bob_wallet_1 = Wallet.create!(
  user_id: bob.id,
  name: "Bob's Hardware Wallet",
  wallet_address: "J0K1L2M3N4O5P6Q7R8S9T",
  wallet_type: "hardware"
)
puts "Created wallet for Bob: #{bob_wallet_1.name}"

puts "Adding coins to wallets..."

WalletsCoin.create!(
  wallet_id: alice_wallet_1.id,
  coin_id: bitcoin.id,
  quantity: 0.5,
  average_buy_price: 45000,
  total_invested: 22500
)
puts "Added Bitcoin to Alice's wallet"

WalletsCoin.create!(
  wallet_id: alice_wallet_1.id,
  coin_id: ethereum.id,
  quantity: 3.2,
  average_buy_price: 3000,
  total_invested: 9600
)
puts "Added Ethereum to Alice's wallet"

WalletsCoin.create!(
  wallet_id: bob_wallet_1.id,
  coin_id: bitcoin.id,
  quantity: 1.2,
  average_buy_price: 50000,
  total_invested: 60000
)
puts "Added Bitcoin to Bob's wallet"

puts "Creating sample transactions..."

Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: bitcoin.id,
  date: DateTime.now - 5,
  transaction_type: "buy",
  quantity: 0.5,
  price_per_coin: 45000,
  total_value: 22500,
  fee: 50
)
puts "Created transaction for Alice"

Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: bitcoin.id,
  date: DateTime.now - 6,
  transaction_type: "buy",
  quantity: 0.5,
  price_per_coin: 46000,
  total_value: 23000,
  fee: 10
)
puts "Created transaction for Alice"

Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: bitcoin.id,
  date: DateTime.now - 6,
  transaction_type: "buy",
  quantity: 0.25,
  price_per_coin: 48000,
  total_value: 12000,
  fee: 200
)
puts "Created transaction for Alice"

Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: ethereum.id,
  date: DateTime.now - 10,
  transaction_type: "buy",
  quantity: 0.5,
  price_per_coin: 1900,
  total_value: 850,
  fee: 5
)
puts "Created transaction for Alice"

Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: ethereum.id,
  date: DateTime.now - 11,
  transaction_type: "buy",
  quantity: 1,
  price_per_coin: 1950,
  total_value: 1950,
  fee: 7.5
)
puts "Created transaction for Alice"



Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: ethereum.id,
  date: DateTime.now - 15,
  transaction_type: "buy",
  quantity: 2,
  price_per_coin: 2100,
  total_value: 4200,
  fee: 15
)
puts "Created transaction for Alice"

Transaction.create!(
  user_id: alice.id,
  wallet_id: alice_wallet_1.id,
  coin_id: ethereum.id,
  date: DateTime.now - 15,
  transaction_type: "buy",
  quantity: 2,
  price_per_coin: 2150,
  total_value: 4300,
  fee: 15
)
puts "Created transaction for Alice"



Transaction.create!(
  user_id: bob.id,
  wallet_id: bob_wallet_1.id,
  coin_id: bitcoin.id,
  date: DateTime.now - 10,
  transaction_type: "buy",
  quantity: 1.2,
  price_per_coin: 50000,
  total_value: 60000,
  fee: 100
)

puts "Created transaction for Bob"
puts "Rebuilding search index"
PgSearch::Multisearch.rebuild(Coin)
PgSearch::Multisearch.rebuild(Wallet)
puts "Seeding completed!"
