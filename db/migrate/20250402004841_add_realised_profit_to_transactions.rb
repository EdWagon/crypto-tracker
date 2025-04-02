class AddRealisedProfitToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :realised_profit, :decimal
  end
end
