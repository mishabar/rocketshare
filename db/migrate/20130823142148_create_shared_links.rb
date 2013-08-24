class CreateSharedLinks < ActiveRecord::Migration
  def change
    create_table :shared_links do |t|
      t.string          :fb_id, :null => false
      t.string          :original_link, :null => false, :limit => 4000
      t.string          :short_link, :null => false

      t.string          :images, :limit => 4000
      t.string          :title, :null => false
      t.string          :description, :limit => 4000

      t.timestamps
    end

    add_index :shared_links, :fb_id
    add_index :shared_links, :short_link
  end
end
