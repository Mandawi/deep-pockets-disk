class CreateRoundPlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :round_players do |t|
      t.integer :round_id
      t.integer :player_id
      t.integer :player_money, default: 0

      t.timestamps
    end
  end
end
