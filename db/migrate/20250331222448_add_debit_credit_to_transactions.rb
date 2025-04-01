class AddDebitCreditToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :debit_credit, :boolean, default: false
  end
end
