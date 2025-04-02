class RenameDebitCreditColumnToDebitInTransactions < ActiveRecord::Migration[7.1]
  def change
    rename_column :transactions, :debit_credit, :debit
  end
end
