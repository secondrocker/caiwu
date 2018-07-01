class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer :subscription_id
      t.string :customer_name              #客户姓名
      t.string :customer_phone             #客户电话
      t.string :deal_source                #成交来源
      t.string :project_name               #项目名
      t.datetime :sub_date                 # 签约日期
      t.integer :customer_type,:limit => 2 # 客户类型 0 A类  #B类
      t.decimal :commision_price,:precision => 12,:scale => 2 #结佣标准
      t.decimal :amout_price,:precision => 12,:scale => 2 #应收佣金
      t.decimal :reduce_price,:precision => 12,:scale => 2 #优惠金额
      t.decimal :reduced_price,:precision => 12,:scale => 2 #已扣优惠
      t.decimal :no_reduced_price,:precision => 12,:scale => 2# 未扣优惠
      t.decimal :real_price,:precision => 12,:scale => 2 #实际金额
      t.string  :remark #备注
      t.timestamps
    end
    add_index :orders,:sub_date
    add_index :orders,:customer_type
  end
end
