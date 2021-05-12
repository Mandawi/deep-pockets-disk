class AddCurrentRoundIdToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :current_round_id, :integer
  end
end
