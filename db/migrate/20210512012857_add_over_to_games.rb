class AddOverToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :over, :boolean
  end
end
