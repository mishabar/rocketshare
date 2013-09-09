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

ActiveRecord::Schema.define(:version => 20130909121502) do

  create_table "shared_links", :force => true do |t|
    t.string   "fb_id",                          :null => false
    t.string   "original_link",  :limit => 4000, :null => false
    t.string   "short_link",                     :null => false
    t.string   "images",         :limit => 4000
    t.string   "title",                          :null => false
    t.string   "description",    :limit => 4000
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "og_title"
    t.string   "og_description", :limit => 4000
    t.string   "og_images",      :limit => 4000
    t.integer  "user_id",                        :null => false
  end

  add_index "shared_links", ["fb_id"], :name => "index_shared_links_on_fb_id"
  add_index "shared_links", ["short_link"], :name => "index_shared_links_on_short_link"

  create_table "stats", :force => true do |t|
    t.integer  "link_id",                   :null => false
    t.integer  "user_id",                   :null => false
    t.date     "date",                      :null => false
    t.integer  "hour",                      :null => false
    t.integer  "android",    :default => 0, :null => false
    t.integer  "ios",        :default => 0, :null => false
    t.integer  "other_os",   :default => 0, :null => false
    t.integer  "views",      :default => 0, :null => false
    t.integer  "facebook",   :default => 0, :null => false
    t.integer  "googleplus", :default => 0, :null => false
    t.integer  "other_sn",   :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "twitter",    :default => 0, :null => false
  end

  add_index "stats", ["link_id", "user_id", "date", "hour"], :name => "index_stats_on_link_id_and_user_id_and_date_and_hour"

  create_table "users", :force => true do |t|
    t.string   "fb_id",      :null => false
    t.string   "name",       :null => false
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users", ["fb_id"], :name => "index_users_on_fb_id"

end
