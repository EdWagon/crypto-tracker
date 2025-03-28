class AddDefautlToTotalValue < ActiveRecord::Migration[7.1]
  def change
    change_column_default :transactions, :total_value, 0.0
  end
end
