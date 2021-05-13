class User < ApplicationRecord
  include Clearance::User
  has_many :game_players
  has_many :games, through: :game_players

  has_many :round_players
  has_many :rounds, through: :round_players
end
