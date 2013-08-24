# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130823161022) do

  create_table "shared_links", :force => true do |t|
    t.string   "fb_id",          :null => false
    t.string   "original_link",  :null => false
    t.string   "short_link",     :null => false
    t.string   "images"
    t.string   "title",          :null => false
    t.string   "description"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "og_title"
    t.string   "og_description"
    t.string   "og_images"
    t.integer  "user_id",        :null => false
  end

  add_index "shared_links", ["fb_id"], :name => "index_shared_links_on_fb_id"
  add_index "shared_links", ["short_link"], :name => "index_shared_links_on_short_link"

  create_table "users", :force => true do |t|
    t.string   "fb_id",      :null => false
    t.string   "name",       :null => false
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users", ["fb_id"], :name => "index_users_on_fb_id"

end
