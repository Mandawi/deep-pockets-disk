class RoundPlayer < ApplicationRecord
  belongs_to :rounds
  belongs_to :users
end
