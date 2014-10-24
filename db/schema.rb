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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140926193300) do

  create_table "infractions", force: true do |t|
    t.string   "inspection_id"
    t.string   "infraction_type"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inspections", id: false, force: true do |t|
    t.string   "id"
    t.string   "premise_id"
    t.date     "date"
    t.string   "inspection_reason"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result"
    t.string   "details"
    t.string   "details_short"
  end

  create_table "locations", force: true do |t|
    t.decimal "lat"
    t.decimal "lng"
  end

  create_table "premises", id: false, force: true do |t|
    t.string   "id"
    t.string   "name"
    t.string   "premise_type"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
  end

end
