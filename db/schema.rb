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

ActiveRecord::Schema.define(:version => 20110913123253) do

  create_table "authorships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "diary_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorships", ["diary_id"], :name => "index_authorships_on_diary_id"
  add_index "authorships", ["user_id", "diary_id"], :name => "index_authorships_on_user_id_and_diary_id", :unique => true
  add_index "authorships", ["user_id"], :name => "index_authorships_on_user_id"

  create_table "diaries", :force => true do |t|
    t.string   "title"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "diary_id"
    t.date     "date"
    t.float    "temperature"
    t.float    "humidity"
    t.text     "action_feed"
    t.text     "action_care"
    t.text     "pet_feces"
    t.text     "pet_physical"
    t.text     "memo"
  end

  add_index "entries", ["date", "diary_id"], :name => "idx_diary_id_date_unique", :unique => true

  create_table "opt_columns", :force => true do |t|
    t.integer  "diary_id"
    t.string   "name"
    t.integer  "col_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
  end

end
