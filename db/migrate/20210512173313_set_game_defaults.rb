class SetGameDefaults < ActiveRecord::Migration[6.1]
  def change
    change_column :games, :over, :boolean, default: false
    change_column :games, :current_round_id, :integer, null: true
  end
end
