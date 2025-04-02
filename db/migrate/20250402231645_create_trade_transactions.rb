class CreateTradeTransactions < ActiveRecord::Migration[7.1]
  def change
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
  end
end
