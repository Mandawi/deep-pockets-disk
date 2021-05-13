class RenamePlayerColumnsToUser < ActiveRecord::Migration[6.1]
  def change
    rename_column :game_players, :player_id, :user_id
    rename_column :round_players, :player_id, :user_id
  end
end
