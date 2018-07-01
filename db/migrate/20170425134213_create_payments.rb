class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.integer :order_id
      t.decimal :money ,precision:20,scale:2
      t.datetime :pay_date
      t.timestamps
    end
    add_index :payments,:order_id
    add_index :payments,:pay_date
  end
end
