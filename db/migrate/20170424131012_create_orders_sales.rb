class CreateOrdersSales < ActiveRecord::Migration[5.1]
  def change
    create_table :orders_sales do |t|
      t.integer :order_id           #签约id
      t.integer :sale_id                   #销售员Id
      t.decimal :rate,precision:10,scale:4 #分单比例
      t.integer :primary_sale              #销售主任  0 非 1 是
      t.timestamps
    end
    add_index :orders_sales,:order_id
    add_index :orders_sales,:sale_id
    add_index :orders_sales,:primary_sale
  end
end
