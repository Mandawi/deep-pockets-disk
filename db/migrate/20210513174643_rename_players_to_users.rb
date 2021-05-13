class RenamePlayersToUsers < ActiveRecord::Migration[6.1]
  def change
    rename_table :players, :users
  end
end
