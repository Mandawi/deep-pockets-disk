class CreateGamePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :game_players do |t|
      t.integer :game_id
      t.integer :player_id
      t.integer :player_total_money, default: 0
      t.integer :player_order

      t.timestamps
    end
  end
end
