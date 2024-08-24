# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_08_24_195021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendar_events", id: :serial, force: :cascade do |t|
    t.string "owner_type", null: false
    t.integer "owner_id", null: false
    t.integer "patrol_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
    t.index ["owner_type", "owner_id"], name: "index_calendar_events_on_owner_type_and_owner_id"
    t.index ["patrol_id", "owner_id", "owner_type"], name: "patrol_unique_to_calendar", unique: true
    t.index ["patrol_id"], name: "index_calendar_events_on_patrol_id"
  end

  create_table "calendars", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "calendar_type"
    t.integer "calendar_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["calendar_type", "calendar_id"], name: "index_calendars_on_calendar_type_and_calendar_id"
    t.index ["user_id", "calendar_type"], name: "index_calendars_on_user_id_and_calendar_type", unique: true
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "classrooms", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "map_link", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["address"], name: "index_classrooms_on_address", unique: true
    t.index ["name"], name: "index_classrooms_on_name", unique: true
  end

  create_table "cpr_classes", id: :serial, force: :cascade do |t|
    t.datetime "time", precision: nil, null: false
    t.integer "students_count"
    t.integer "class_size", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "classroom_id"
    t.index ["classroom_id"], name: "index_cpr_classes_on_classroom_id"
    t.index ["time", "classroom_id"], name: "index_cpr_classes_on_time_and_classroom_id", unique: true
  end

  create_table "cpr_external_students", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_cpr_external_students_on_email", unique: true
    t.index ["first_name", "last_name"], name: "index_cpr_external_students_on_first_name_and_last_name", unique: true
  end

  create_table "cpr_students", force: :cascade do |t|
    t.bigint "cpr_class_id", null: false
    t.boolean "email_sent"
    t.string "email_token"
    t.bigint "cpr_year_id", null: false
    t.string "student_type", null: false
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpr_class_id"], name: "index_cpr_students_on_cpr_class_id"
    t.index ["cpr_year_id"], name: "index_cpr_students_on_cpr_year_id"
    t.index ["student_type", "student_id", "cpr_year_id"], name: "idx_on_student_type_student_id_cpr_year_id_731fdad6dc", unique: true
    t.index ["student_type", "student_id"], name: "index_cpr_students_on_student"
  end

  create_table "cpr_years", force: :cascade do |t|
    t.date "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_cpr_years_on_year", unique: true
  end

  create_table "duty_days", id: :serial, force: :cascade do |t|
    t.integer "season_id"
    t.integer "team_id"
    t.date "date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["season_id"], name: "index_duty_days_on_season_id"
    t.index ["team_id", "date"], name: "index_duty_days_on_team_id_and_date", unique: true
    t.index ["team_id"], name: "index_duty_days_on_team_id"
  end

  create_table "google_calendars", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "calendar_id"
    t.string "refresh_token"
  end

  create_table "patrol_responsibilities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "version"
    t.string "runs"
    t.string "ropelines"
    t.string "other"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "role_id"
    t.index ["name", "version"], name: "index_patrol_responsibilities_on_name_and_version", unique: true
    t.index ["role_id"], name: "index_patrol_responsibilities_on_role_id"
  end

  create_table "patrols", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "duty_day_id"
    t.integer "patrol_responsibility_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["duty_day_id"], name: "index_patrols_on_duty_day_id"
    t.index ["patrol_responsibility_id", "duty_day_id"], name: "index_patrols_on_patrol_responsibility_id_and_duty_day_id", unique: true
    t.index ["patrol_responsibility_id"], name: "index_patrols_on_patrol_responsibility_id"
    t.index ["user_id", "duty_day_id"], name: "index_patrols_on_user_id_and_duty_day_id", unique: true
    t.index ["user_id"], name: "index_patrols_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "roster_spots", id: :serial, force: :cascade do |t|
    t.integer "season_id"
    t.integer "team_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["season_id", "user_id"], name: "index_roster_spots_on_season_id_and_user_id", unique: true
    t.index ["season_id"], name: "index_roster_spots_on_season_id"
    t.index ["team_id"], name: "index_roster_spots_on_team_id"
    t.index ["user_id"], name: "index_roster_spots_on_user_id"
  end

  create_table "seasons", id: :serial, force: :cascade do |t|
    t.string "name"
    t.date "start"
    t.date "end"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_seasons_on_name", unique: true
  end

  create_table "students", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.boolean "email_sent"
    t.integer "cpr_class_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cpr_class_id"], name: "index_students_on_cpr_class_id"
    t.index ["first_name", "last_name"], name: "index_students_on_first_name_and_last_name", unique: true
  end

  create_table "substitutions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "patrol_id"
    t.string "reason"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "sub_id"
    t.boolean "accepted", default: false
    t.index ["patrol_id"], name: "index_substitutions_on_patrol_id"
    t.index ["sub_id"], name: "index_substitutions_on_sub_id"
    t.index ["user_id"], name: "index_substitutions_on_user_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at", precision: nil
    t.boolean "activated", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.boolean "reserve", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "calendar_events", "patrols"
  add_foreign_key "calendars", "users"
  add_foreign_key "cpr_classes", "classrooms"
  add_foreign_key "cpr_students", "cpr_classes"
  add_foreign_key "cpr_students", "cpr_years"
  add_foreign_key "duty_days", "seasons"
  add_foreign_key "duty_days", "teams"
  add_foreign_key "patrol_responsibilities", "roles"
  add_foreign_key "patrols", "duty_days"
  add_foreign_key "patrols", "patrol_responsibilities"
  add_foreign_key "patrols", "users"
  add_foreign_key "roster_spots", "seasons"
  add_foreign_key "roster_spots", "teams"
  add_foreign_key "roster_spots", "users"
  add_foreign_key "students", "cpr_classes"
  add_foreign_key "substitutions", "patrols"
  add_foreign_key "substitutions", "users"
  add_foreign_key "substitutions", "users", column: "sub_id"
end
