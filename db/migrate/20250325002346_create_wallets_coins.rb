class CreateWalletsCoins < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets_coins do |t|
      t.references :wallet, null: false, foreign_key: true
      t.references :coin, null: false, foreign_key: true
      t.decimal :quantity
      t.decimal :average_buy_price
      t.decimal :total_invested

      t.timestamps
    end
  end
end
