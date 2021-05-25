class Round < ApplicationRecord
  has_many :round_players
  has_many :users, through: :round_players
  default_scope { order(order: :asc) }

  after_commit :change_round_status, on: :update

  def next
    game_rounds = Game.find(self.game_id)
    next_round_order = self.order + 1
    return game_rounds.where(order: next_round_order).first
  end

  def change_round_status
    if self.saved_change_to_over? and self.over?
      update_game_room(:started)
    end
  end

  def update_game_room(attribute)
    current_round = Round.find(self.next)
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
  end
end