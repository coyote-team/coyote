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

ActiveRecord::Schema.define(version: 20170727163758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "image_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["image_id"], name: "index_assignments_on_image_id", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",                null: false
    t.string   "auditable_type",              null: false
    t.integer  "associated_id",               null: false
    t.string   "associated_type",             null: false
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "contexts", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "descriptions", force: :cascade do |t|
    t.string   "locale",     default: "en"
    t.text     "text"
    t.integer  "status_id",                      null: false
    t.integer  "image_id",                       null: false
    t.integer  "metum_id",                       null: false
    t.integer  "user_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "license",    default: "cc0-1.0"
  end

  add_index "descriptions", ["image_id"], name: "index_descriptions_on_image_id", using: :btree
  add_index "descriptions", ["metum_id"], name: "index_descriptions_on_metum_id", using: :btree
  add_index "descriptions", ["status_id"], name: "index_descriptions_on_status_id", using: :btree
  add_index "descriptions", ["user_id"], name: "index_descriptions_on_user_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "path"
    t.integer  "website_id",                         null: false
    t.integer  "context_id",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "canonical_id"
    t.integer  "assignments_count",  default: 0,     null: false
    t.integer  "descriptions_count", default: 0,     null: false
    t.text     "title"
    t.boolean  "priority",           default: false, null: false
    t.integer  "status_code",        default: 0,     null: false
    t.text     "page_urls"
  end

  add_index "images", ["context_id"], name: "index_images_on_context_id", using: :btree
  add_index "images", ["website_id"], name: "index_images_on_website_id", using: :btree

  create_table "meta", force: :cascade do |t|
    t.string   "title"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",                    null: false
    t.integer  "taggable_id",               null: false
    t.string   "taggable_type",             null: false
    t.integer  "tagger_id",                 null: false
    t.string   "tagger_type",               null: false
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",                       null: false
    t.integer "taggings_count", default: 0, null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "strategy"
  end

  add_foreign_key "assignments", "images", on_update: :cascade, on_delete: :cascade
  add_foreign_key "assignments", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "descriptions", "images", on_update: :cascade, on_delete: :cascade
  add_foreign_key "descriptions", "meta", on_update: :cascade, on_delete: :cascade
  add_foreign_key "descriptions", "statuses", on_update: :cascade, on_delete: :cascade
  add_foreign_key "descriptions", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "images", "contexts", on_update: :cascade, on_delete: :cascade
  add_foreign_key "images", "websites", on_update: :cascade, on_delete: :cascade
end
