class CreateRounds < ActiveRecord::Migration[6.1]
  def change
    create_table :rounds do |t|
      t.integer :game_id
      t.boolean :over, default: false
      t.string :topic
      t.string :sentence
      t.text :opened_letters, :text, array: true, default: []
      t.integer :current_player_id
      t.integer :order

      t.timestamps
    end
  end
end
