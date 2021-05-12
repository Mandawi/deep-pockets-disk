class DropScore < ActiveRecord::Migration[6.1]
  def change
    drop_table :scores
  end
end
