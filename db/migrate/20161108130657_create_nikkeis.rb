class CreateNikkeis < ActiveRecord::Migration[5.0]
  def change
    create_table :nikkeis do |t|
      t.date    :date, null: false
      t.integer :last_price, null: false
      t.integer :open_price, null: false
      t.integer :high_price, null: false
      t.integer :low_price, null: false
      t.timestamps
    end
  end
end
