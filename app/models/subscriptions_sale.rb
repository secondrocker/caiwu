class SubscriptionsSale < ApplicationRecord
  belongs_to :subscription
  belongs_to :sale
end
