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

ActiveRecord::Schema.define(version: 20161018053323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendar_events", force: :cascade do |t|
    t.string   "owner_type",        null: false
    t.integer  "owner_id",          null: false
    t.integer  "patrol_id"
    t.string   "encrypted_uuid"
    t.string   "encrypted_uuid_iv"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["owner_type", "owner_id"], name: "index_calendar_events_on_owner_type_and_owner_id", using: :btree
    t.index ["patrol_id", "owner_id", "owner_type"], name: "patrol_unique_to_calendar", unique: true, using: :btree
    t.index ["patrol_id"], name: "index_calendar_events_on_patrol_id", using: :btree
  end

  create_table "calendars", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "calendar_type"
    t.integer  "calendar_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["calendar_type", "calendar_id"], name: "index_calendars_on_calendar_type_and_calendar_id", using: :btree
    t.index ["user_id", "calendar_type"], name: "index_calendars_on_user_id_and_calendar_type", unique: true, using: :btree
    t.index ["user_id"], name: "index_calendars_on_user_id", using: :btree
  end

  create_table "duty_days", force: :cascade do |t|
    t.integer  "season_id"
    t.integer  "team_id"
    t.date     "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_duty_days_on_season_id", using: :btree
    t.index ["team_id", "date"], name: "index_duty_days_on_team_id_and_date", unique: true, using: :btree
    t.index ["team_id"], name: "index_duty_days_on_team_id", using: :btree
  end

  create_table "google_calendars", force: :cascade do |t|
    t.string   "encrypted_calendar_id"
    t.string   "encrypted_calendar_id_iv"
    t.string   "encrypted_refresh_token"
    t.string   "encrypted_refresh_token_iv"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "patrol_responsibilities", force: :cascade do |t|
    t.string   "name"
    t.integer  "version"
    t.string   "runs"
    t.string   "ropelines"
    t.string   "other"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "role_id"
    t.index ["name", "version"], name: "index_patrol_responsibilities_on_name_and_version", unique: true, using: :btree
    t.index ["role_id"], name: "index_patrol_responsibilities_on_role_id", using: :btree
  end

  create_table "patrols", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "duty_day_id"
    t.integer  "patrol_responsibility_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["duty_day_id"], name: "index_patrols_on_duty_day_id", using: :btree
    t.index ["patrol_responsibility_id", "duty_day_id"], name: "index_patrols_on_patrol_responsibility_id_and_duty_day_id", unique: true, using: :btree
    t.index ["patrol_responsibility_id"], name: "index_patrols_on_patrol_responsibility_id", using: :btree
    t.index ["user_id", "duty_day_id"], name: "index_patrols_on_user_id_and_duty_day_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_patrols_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "roster_spots", force: :cascade do |t|
    t.integer  "season_id"
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "user_id"], name: "index_roster_spots_on_season_id_and_user_id", unique: true, using: :btree
    t.index ["season_id"], name: "index_roster_spots_on_season_id", using: :btree
    t.index ["team_id"], name: "index_roster_spots_on_team_id", using: :btree
    t.index ["user_id"], name: "index_roster_spots_on_user_id", using: :btree
  end

  create_table "seasons", force: :cascade do |t|
    t.string   "name"
    t.date     "start"
    t.date     "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_seasons_on_name", unique: true, using: :btree
  end

  create_table "substitutions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "patrol_id"
    t.string   "reason"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "sub_id"
    t.boolean  "accepted",   default: false
    t.index ["patrol_id"], name: "index_substitutions_on_patrol_id", using: :btree
    t.index ["sub_id"], name: "index_substitutions_on_sub_id", using: :btree
    t.index ["user_id"], name: "index_substitutions_on_user_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "activated",              default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  add_foreign_key "calendar_events", "patrols"
  add_foreign_key "calendars", "users"
  add_foreign_key "duty_days", "seasons"
  add_foreign_key "duty_days", "teams"
  add_foreign_key "patrol_responsibilities", "roles"
  add_foreign_key "patrols", "duty_days"
  add_foreign_key "patrols", "patrol_responsibilities"
  add_foreign_key "patrols", "users"
  add_foreign_key "roster_spots", "seasons"
  add_foreign_key "roster_spots", "teams"
  add_foreign_key "roster_spots", "users"
  add_foreign_key "substitutions", "patrols"
  add_foreign_key "substitutions", "users"
  add_foreign_key "substitutions", "users", column: "sub_id"
end
