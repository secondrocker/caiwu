class OrdersSale < ApplicationRecord
  belongs_to :order
  belongs_to :sale
end
