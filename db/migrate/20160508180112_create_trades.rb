class CreateTrades < ActiveRecord::Migration[5.0]
  def change
    create_table :trades do |t|
      t.integer :user_id, default: 0, null: false
      t.integer :trade_type,  default: 0, null: false
      t.datetime  :trade_datetime,  null: false
      t.string  :brand_name
      t.integer :product_price
      t.integer :trade_quantity
      t.integer :trade_amount
      t.integer :gain_loss_amount
      t.date  :sq_date
      t.timestamps
    end
  end
end
