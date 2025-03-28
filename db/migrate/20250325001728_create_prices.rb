class CreatePrices < ActiveRecord::Migration[7.1]
  def change
    create_table :prices do |t|
      t.references :coin, null: false, foreign_key: true
      t.decimal :price
      t.decimal :market_cap
      t.datetime :date
      t.decimal :price_change_24h
      t.decimal :price_change_percentage_24h
      t.decimal :volume_24h
      t.decimal :circulating_supply
      t.decimal :total_supply
      t.decimal :max_supply
      t.decimal :all_time_high
      t.datetime :all_time_high_date

      t.timestamps
    end
  end
end
