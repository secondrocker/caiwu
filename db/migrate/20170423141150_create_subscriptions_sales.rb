class CreateSubscriptionsSales < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions_sales do |t|
      t.integer :subscription_id           #认购id
      t.integer :sale_id                   #销售员Id
      t.decimal :rate,precision:10,scale:4 #分单比例
      t.integer :primary_sale              #销售主任  0 非 1 是
      t.timestamps
    end
    add_index :subscriptions_sales,:subscription_id
    add_index :subscriptions_sales,:sale_id
    add_index :subscriptions_sales,:primary_sale
  end
end
