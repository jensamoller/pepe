# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081017144536) do

  create_table "club_urls", :force => true do |t|
    t.integer  "url_id",     :null => false
    t.integer  "club_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clubs", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.integer  "year_founded"
    t.string   "date_founded"
    t.string   "country"
    t.string   "chairman"
    t.string   "manager"
    t.string   "stadium"
    t.string   "league"
    t.string   "nickname"
    t.string   "crest_url"
    t.text     "wikipedia_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.integer  "player_id",     :null => false
    t.integer  "club_id",       :null => false
    t.integer  "start_year"
    t.integer  "end_year"
    t.string   "contract_type", :null => false
    t.integer  "apperances"
    t.integer  "goals"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string   "given_name"
    t.string   "name"
    t.date     "birthday",       :default => '1975-10-30'
    t.integer  "height",         :default => 0
    t.integer  "jersey_number",  :default => 0
    t.integer  "url_id",                                   :null => false
    t.string   "birth_country"
    t.string   "birth_city"
    t.string   "image_url"
    t.text     "wikipedia_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unparsable_urls", :force => true do |t|
    t.string   "url",        :null => false
    t.datetime "visited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "urls", :force => true do |t|
    t.string   "url",        :null => false
    t.datetime "visited"
    t.integer  "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
