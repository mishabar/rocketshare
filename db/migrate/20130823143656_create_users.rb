class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string      :fb_id, :null => false
      t.string      :name, :null => false
      t.string      :email

      t.timestamps
    end

    add_index :users, :fb_id
  end
end
