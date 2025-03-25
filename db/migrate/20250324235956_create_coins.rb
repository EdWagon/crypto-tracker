class CreateCoins < ActiveRecord::Migration[7.1]
  def change
    create_table :coins do |t|
      t.string :name
      t.string :symbol
      t.string :api_id
      t.string :logo_url
      t.string :website_url

      t.timestamps
    end
  end
end
