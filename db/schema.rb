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
    t.integer "market_cap_rank"
    t.decimal "high_24h"
    t.decimal "low_24h"
    t.decimal "market_cap_change_24h"
    t.decimal "market_cap_change_percentage_24h"
    t.decimal "all_time_high_change_percentage"
    t.decimal "all_time_low"
    t.decimal "all_time_low_change_percentage"
    t.datetime "all_time_low_date"
    t.decimal "price_change_percentage_1h_aud"
    t.decimal "price_change_percentage_24h_aud"
    t.decimal "price_change_percentage_7d_aud"
    t.decimal "price_change_percentage_30d_aud"
    t.decimal "price_change_percentage_1y_aud"
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

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
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
    t.boolean "admin", default: false, null: false
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
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
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
