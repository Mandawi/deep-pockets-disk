class RenameUsersToPlayers < ActiveRecord::Migration[6.1]
  def change
    rename_table :users, :players
  end
end
