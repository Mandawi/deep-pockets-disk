class Game < ApplicationRecord
  has_many :game_players
  has_many :users, through: :game_players
  has_many :rounds

  after_create_commit { broadcast_prepend_later_to 'games' }
  after_destroy_commit { broadcast_remove_to 'games' }

  default_scope { order(created_at: :desc) }

  def next_player(current_player)
    current_game_player = self.game_players.where(user_id: current_player.id).first
    next_player_order = current_game_player.player_order + 1
    next_game_player = self.game_players.where(player_order: next_player_order).first || self.game_players.first
    return User.find(next_game_player.user_id)
  end
end
