class RemoveCurrentRoundFromGames < ActiveRecord::Migration[6.1]
  def change
    remove_column :games, :current_round, :string
  end
end
