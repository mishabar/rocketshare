class AddTwitterToStats < ActiveRecord::Migration
  def change
    add_column :stats, :twitter, :integer, :null => false, :default => 0
  end
end
