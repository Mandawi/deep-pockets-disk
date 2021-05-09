class AddCurrentStepToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :current_step, :string, default: "first"
  end
end
