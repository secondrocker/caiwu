class Subscription < ApplicationRecord
  has_many :subscriptions_sales,dependent: :destroy
  has_many :sales,through: :subscriptions_sales
  has_one :order
  has_many :payments
  accepts_nested_attributes_for :subscriptions_sales, allow_destroy: true

  def primary_sale
    self.subscriptions_sales.detect{|x| x.primary_sale == 1}.try(:sale)
  end

  def other_sales
    self.subscriptions_sales.select{|x| x.primary_sale == 0}.map(&:sale)
  end

  def generate_order
    return if self.order
    new_order = Order.create self.attributes.reject{|k,_|[:id,:sub_date].include?(k.to_sym)}.merge(subscription_id: self.id)
    self.subscriptions_sales.each do |ss|
      new_order.orders_sales.create sale_id:ss.sale_id,rate:ss.rate,primary_sale:ss.primary_sale
    end
  end
end
