class ReplaceIdsWithReferences < ActiveRecord::Migration[6.1]
  def change
    remove_column :game_players, :game_id
    remove_column :game_players, :user_id

    add_reference :game_players, :game, index: true
    add_reference :game_players, :user, index: true

    remove_column :round_players, :round_id
    remove_column :round_players, :user_id

    add_reference :round_players, :round, index: true
    add_reference :round_players, :user, index: true
  end
end
