class AddBestPossible < ActiveRecord::Migration
  def change
    add_column :brackets, :best_possible, :integer, default: 20_000
    add_index :brackets, :best_possible
  end
end
