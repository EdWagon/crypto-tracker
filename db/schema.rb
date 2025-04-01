# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_31_222448) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "coins", force: :cascade do |t|
    t.string "name"
    t.string "symbol"
    t.string "api_id"
    t.string "logo_url"
    t.string "website_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "coin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_id"], name: "index_messages_on_coin_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "prices", force: :cascade do |t|
    t.bigint "coin_id", null: false
    t.decimal "price"
    t.decimal "market_cap"
    t.datetime "date"
    t.decimal "price_change_24h"
    t.decimal "price_change_percentage_24h"
    t.decimal "volume_24h"
    t.decimal "circulating_supply"
    t.decimal "total_supply"
    t.decimal "max_supply"
    t.decimal "all_time_high"
    t.datetime "all_time_high_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_id"], name: "index_prices_on_coin_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "trade_transactions", force: :cascade do |t|
    t.string "transaction_type"
    t.bigint "first_transaction_id", null: false
    t.bigint "second_transaction_id"
    t.bigint "third_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_transaction_id"], name: "index_trade_transactions_on_first_transaction_id"
    t.index ["second_transaction_id"], name: "index_trade_transactions_on_second_transaction_id"
    t.index ["third_transaction_id"], name: "index_trade_transactions_on_third_transaction_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "wallet_id", null: false
    t.bigint "coin_id", null: false
    t.datetime "date"
    t.string "transaction_type"
    t.decimal "quantity"
    t.decimal "price_per_coin"
    t.decimal "total_value", default: "0.0"
    t.decimal "fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "debit_credit", default: false
    t.index ["coin_id"], name: "index_transactions_on_coin_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "nickname"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "wallet_address"
    t.string "wallet_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  create_table "wallets_coins", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.bigint "coin_id", null: false
    t.decimal "quantity"
    t.decimal "average_buy_price"
    t.decimal "total_invested"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_id"], name: "index_wallets_coins_on_coin_id"
    t.index ["wallet_id"], name: "index_wallets_coins_on_wallet_id"
  end

  create_table "watchlists", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  create_table "watchlists_coins", force: :cascade do |t|
    t.bigint "watchlist_id", null: false
    t.bigint "coin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coin_id"], name: "index_watchlists_coins_on_coin_id"
    t.index ["watchlist_id"], name: "index_watchlists_coins_on_watchlist_id"
  end

  add_foreign_key "messages", "coins"
  add_foreign_key "messages", "users"
  add_foreign_key "prices", "coins"
  add_foreign_key "trade_transactions", "transactions", column: "first_transaction_id"
  add_foreign_key "trade_transactions", "transactions", column: "second_transaction_id"
  add_foreign_key "trade_transactions", "transactions", column: "third_transaction_id"
  add_foreign_key "transactions", "coins"
  add_foreign_key "transactions", "users"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "wallets", "users"
  add_foreign_key "wallets_coins", "coins"
  add_foreign_key "wallets_coins", "wallets"
  add_foreign_key "watchlists", "users"
  add_foreign_key "watchlists_coins", "coins"
  add_foreign_key "watchlists_coins", "watchlists"
end
