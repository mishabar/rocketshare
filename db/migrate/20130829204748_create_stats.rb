class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer         :link_id, :null => false
      t.integer         :user_id, :null => false
      t.date            :date, :null => false
      t.integer         :hour, :null => false
      t.integer         :android, :null=> false, :default => 0
      t.integer         :ios, :null=> false, :default => 0
      t.integer         :other_os, :null=> false, :default => 0
      t.integer         :views, :null=> false, :default => 0
      t.integer         :facebook, :null=> false, :default => 0
      t.integer         :googleplus, :null=> false, :default => 0
      t.integer         :other_sn, :null=> false, :default => 0

      t.timestamps
    end

    add_index :stats, [:link_id, :user_id, :date, :hour]
  end
end
