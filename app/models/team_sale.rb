class TeamSale < ApplicationRecord
  belongs_to :team
  belongs_to :sale
end
