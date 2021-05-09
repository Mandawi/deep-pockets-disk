class AddOpenedLettersToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :opened_letters, :text, array: true, default: []
  end
end
