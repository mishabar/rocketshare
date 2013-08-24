class AddOpenGraphFieldsToSharedLinks < ActiveRecord::Migration
  def change
    add_column :shared_links, :og_title, :string
    add_column :shared_links, :og_description, :string, :limit => 4000
    add_column :shared_links, :og_images, :string, :limit => 4000

    add_column :shared_links, :user_id, :integer, :null => false
  end
end
