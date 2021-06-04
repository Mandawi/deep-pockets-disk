require_dependency './lib/games_utils'
class Game < ApplicationRecord
  include ActionView::RecordIdentifier
  include ActionView::Helpers
  include Clearance::Authentication

  has_many :game_players
  has_many :users, through: :game_players
  has_many :rounds
  
  after_create_commit { broadcast_prepend_to 'games' }
  after_destroy_commit { broadcast_remove_to 'games' }
  after_commit :change_game_status, on: :update

  default_scope { order(created_at: :desc) }

  def next_player(current_player)
    current_game_player = self.game_players.where(user_id: current_player.id).first
    next_player_order = current_game_player.player_order + 1
    next_game_player = self.game_players.where(player_order: next_player_order).first || self.game_players.first
    return User.find(next_game_player.user_id)
  end

  def change_game_status
    if self.saved_change_to_started? and self.started?
      update_game_room(:started)
    end
  end

  def update_game_room(attribute)
    current_round = Round.find(self.current_round_id)
    current_player = User.find(current_round.current_player_id)
    starting_players_money = current_round.round_players.map{ |round_player| "#{ GamesController.helpers.get_username(User.find(round_player.user_id).email)}: #{ round_player.player_money }" }
    broadcast_replace_to  [self, attribute], 
                          target: "#{dom_id(self)}_room_chooser", 
                          partial: "games/room_chooser", 
                          locals: { 
                            game: self, 
                            disk_content: GamesUtils.get_disk_content,
                            sentence: current_round.sentence, 
                            round: current_round,
                            player: current_player,
                            topic: current_round.topic,
                            opened_letters: current_round.opened_letters,
                            players_money: starting_players_money,
                          }
  broadcast_replace_later_to  [self, attribute], 
                          target: "#{dom_id(self)}_room_chooser", 
                          partial: "games/room_chooser", 
                          locals: { 
                            game: self, 
                            disk_content: GamesUtils.get_disk_content,
                            sentence: current_round.sentence, 
                            round: current_round,
                            player: current_player,
                            topic: current_round.topic,
                            opened_letters: current_round.opened_letters,
                            players_money: starting_players_money,
                          }
  end
end
