class ChangeCurrentStep < ActiveRecord::Migration[6.1]
  def change
    rename_column :games, :current_step, :current_round
  end
end
