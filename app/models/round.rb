class Round < ApplicationRecord
  has_many :round_players
  has_many :users, through: :round_players
end
