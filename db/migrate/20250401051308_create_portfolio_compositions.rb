class CreatePortfolioCompositions < ActiveRecord::Migration[7.1]
  def change
    create_table :portfolio_compositions do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.references :coin, null: false, foreign_key: true
      t.decimal :cumulative_amount, precision: 18, scale: 8
      t.decimal :total_value, precision: 18, scale: 2
      t.decimal :amount_invested, precision: 18, scale: 2

      t.timestamps
    end

    # Add an index for faster querying by date
    add_index :portfolio_compositions, :date

    # Add a unique index to prevent duplicate entries for the same user, coin, and date
    add_index :portfolio_compositions, [:user_id, :coin_id, :date], unique: true
  end
end
