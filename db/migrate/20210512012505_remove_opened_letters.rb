class RemoveOpenedLetters < ActiveRecord::Migration[6.1]
  def change
    remove_column :games, :opened_letters
  end
end
