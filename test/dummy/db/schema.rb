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

ActiveRecord::Schema.define(version: 20160229125824) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "threads_pad_job_logs", force: :cascade do |t|
    t.integer  "job_reflection_id"
    t.integer  "level"
    t.text     "msg"
    t.datetime "created_at",        null: false
    t.integer  "group_id"
  end

  add_index "threads_pad_job_logs", ["job_reflection_id"], name: "index_threads_pad_job_logs_on_job_reflection_id", using: :btree

  create_table "threads_pad_jobs", force: :cascade do |t|
    t.boolean "terminated"
    t.boolean "done"
    t.string  "result"
    t.integer "group_id"
    t.integer "integer"
    t.integer "max"
    t.integer "current"
    t.integer "min"
    t.boolean "started"
    t.boolean "destroy_on_finish"
    t.string  "thread_id"
  end

  add_index "threads_pad_jobs", ["group_id"], name: "index_threads_pad_jobs_on_group_id", using: :btree

end
