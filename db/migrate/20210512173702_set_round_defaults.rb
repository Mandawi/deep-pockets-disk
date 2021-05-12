class SetRoundDefaults < ActiveRecord::Migration[6.1]
  def change
    change_column :rounds, :current_player_id, :integer, null: true
  end
end
