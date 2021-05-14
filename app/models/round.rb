class Round < ApplicationRecord
  has_many :round_players
  has_many :users, through: :round_players
  default_scope { order(order: :asc) }

  def next
    game_rounds = Game.find(self.game_id)
    next_round_order = self.order + 1
    return game_rounds.where(order: next_round_order)
  end
end