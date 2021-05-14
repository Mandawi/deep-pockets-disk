class GamePlayer < ApplicationRecord
  belongs_to :game
  belongs_to :user
  default_scope { order(player_order: :asc) }
end
