class RoundPlayer < ApplicationRecord
  belongs_to :round
  belongs_to :user
end
