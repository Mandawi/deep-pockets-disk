class GamePlayer < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :game
  belongs_to :user
  default_scope { order(player_order: :asc) }

  after_create_commit -> {
    broadcast_append_to [game, :game_players], target: "#{dom_id(game)}_game_players"
  }
end
