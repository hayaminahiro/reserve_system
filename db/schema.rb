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

ActiveRecord::Schema.define(version: 2019_12_12_133244) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_end_time", default: "2020-01-10 19:00:00"
    t.string "status"
    t.integer "superior_id"
    t.datetime "apply_month"
    t.integer "month_approval", default: 1
    t.boolean "month_check", default: false
    t.boolean "tomorrow_check"
    t.integer "attendance_approval", default: 1
    t.boolean "attendance_check", default: false
    t.datetime "change_started"
    t.datetime "change_finished"
    t.integer "superior_id_at"
    t.datetime "apply_month_at"
    t.datetime "apply_month_over"
    t.datetime "job_end_time"
    t.boolean "tomorrow_check_at", default: false
    t.string "job_content"
    t.integer "superior_id_over"
    t.integer "overtime_approval", default: 1
    t.boolean "overtime_check", default: false
    t.boolean "tomorrow_check_over", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2019-07-01 07:30:00"
    t.datetime "work_time", default: "2019-07-01 08:00:00"
    t.datetime "designated_work_start_time", default: "2020-01-10 09:00:00"
    t.datetime "designated_work_end_time", default: "2020-01-10 18:00:00"
    t.integer "employee_number"
    t.string "uid"
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2019-07-01 07:30:00"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
