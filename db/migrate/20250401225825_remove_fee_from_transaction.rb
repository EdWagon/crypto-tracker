class RemoveFeeFromTransaction < ActiveRecord::Migration[7.1]
  def change
    remove_column :transactions, :fee, :decimal
  end
end
