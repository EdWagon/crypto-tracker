class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :wallet_address
      t.string :wallet_type

      t.timestamps
    end
  end
end
