class AddStartedColumnToGames < ActiveRecord::Migration[6.1]
  def change
     add_column :games, :started, :boolean, default: false
  end
end
