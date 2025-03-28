class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :wallet, null: false, foreign_key: true
      t.references :coin, null: false, foreign_key: true
      t.datetime :date
      t.string :transaction_type
      t.decimal :quantity
      t.decimal :price_per_coin
      t.decimal :total_value
      t.decimal :fee

      t.timestamps
    end
  end
end
