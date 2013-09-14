class CreateLeaderboard < ActiveRecord::Migration
  def up
    create_table :leaderboard do|t|
      t.integer         :user_id, :null => false
      t.string          :fb_id, :null => false
      t.integer         :shares, :null => false, :default => 0
      t.integer         :views, :null => false, :default => 0
      t.integer         :miles, :null => false, :default => 0

      t.timestamps
    end

    add_index :leaderboard, :fb_id
    add_index :leaderboard, :miles
  end

  def down
    drop_table :leaderboard
  end
end
