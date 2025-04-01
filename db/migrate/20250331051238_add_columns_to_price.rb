class AddColumnsToPrice < ActiveRecord::Migration[7.1]
  def change
    add_column :prices, :market_cap_rank, :integer
    add_column :prices, :high_24h, :decimal
    add_column :prices, :low_24h, :decimal
    add_column :prices, :market_cap_change_24h, :decimal
    add_column :prices, :market_cap_change_percentage_24h, :decimal
    add_column :prices, :all_time_high_change_percentage, :decimal
    add_column :prices, :all_time_low, :decimal
    add_column :prices, :all_time_low_change_percentage, :decimal
    add_column :prices, :all_time_low_date, :datetime
    add_column :prices, :price_change_percentage_1h_aud, :decimal
    add_column :prices, :price_change_percentage_24h_aud, :decimal
    add_column :prices, :price_change_percentage_7d_aud, :decimal
    add_column :prices, :price_change_percentage_30d_aud, :decimal
    add_column :prices, :price_change_percentage_1y_aud, :decimal
  end
end
