class Order < ApplicationRecord
  has_many :orders_sales,dependent: :destroy
  has_many :sales,through: :orders_sales
  has_many :payments,dependent: :destroy
  belongs_to :subscription,optional:true

  accepts_nested_attributes_for :orders_sales, allow_destroy: true
  accepts_nested_attributes_for :payments, allow_destroy: true
  def primary_sale
    self.orders_sales.detect{|x| x.primary_sale == 1}.try(:sale)
  end

  def other_sales
    self.orders_sales.select{|x| x.primary_sale == 0}.map(&:sale)
  end
end
