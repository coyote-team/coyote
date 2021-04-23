# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_21_221224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_enum :membership_role, [
    "guest",
    "viewer",
    "author",
    "editor",
    "admin",
    "owner",
  ], force: :cascade

  create_enum :representation_status, [
    "ready_to_review",
    "approved",
    "not_approved",
  ], force: :cascade

  create_enum :resource_status, [
    "active",
    "archived",
    "deleted",
    "not_found",
    "unexpected_response",
  ], force: :cascade

  create_enum :resource_type, [
    "collection",
    "dataset",
    "event",
    "image",
    "interactive_resource",
    "moving_image",
    "physical_object",
    "service",
    "software",
    "sound",
    "still_image",
    "text",
  ], force: :cascade

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "assignments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "resource_id", null: false
    t.integer "status", default: 0, null: false
    t.index ["resource_id", "user_id"], name: "index_assignments_on_resource_id_and_user_id", unique: true
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id", null: false
    t.string "auditable_type", null: false
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username", default: "Unknown", null: false
    t.string "action", null: false
    t.jsonb "audited_changes"
    t.integer "version", default: 0, null: false
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", null: false
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.string "user_agent"
    t.datetime "expires_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token", "user_id"], name: "index_auth_tokens_on_token_and_user_id"
    t.index ["token"], name: "index_auth_tokens_on_token"
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
  end

  create_table "imports", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.json "sheet_mappings"
    t.integer "status", default: 0, null: false
    t.integer "successes", default: 0, null: false
    t.integer "failures", default: 0, null: false
    t.integer "new_records", default: 0, null: false
    t.integer "duplicate_records", default: 0, null: false
    t.integer "changed_records", default: 0, null: false
    t.string "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_imports_on_organization_id"
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.citext "recipient_email", null: false
    t.citext "token", null: false
    t.bigint "sender_user_id", null: false
    t.bigint "recipient_user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "redeemed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "viewer", null: false, enum_name: "membership_role"
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["recipient_email", "token"], name: "index_invitations_on_recipient_email_and_token"
    t.index ["recipient_user_id"], name: "index_invitations_on_recipient_user_id"
    t.index ["sender_user_id"], name: "index_invitations_on_sender_user_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.citext "name", null: false
    t.string "description", null: false
    t.citext "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "guest", null: false, enum_name: "membership_role"
    t.boolean "active", default: true
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
  end

  create_table "meta", id: :serial, force: :cascade do |t|
    t.citext "name", null: false
    t.text "instructions", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "organization_id", null: false
    t.boolean "is_required", default: false, null: false
    t.index ["organization_id", "name"], name: "index_meta_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_meta_on_organization_id"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_license_id", null: false
    t.boolean "is_deleted", default: false
    t.string "footer"
    t.boolean "allow_authors_to_claim_resources", default: false, null: false
    t.index ["is_deleted"], name: "index_organizations_on_is_deleted"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "password_resets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_password_resets_on_user_id"
  end

  create_table "representation_rejections", force: :cascade do |t|
    t.bigint "representation_id"
    t.bigint "user_id"
    t.text "reason", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["representation_id"], name: "index_representation_rejections_on_representation_id"
    t.index ["user_id"], name: "index_representation_rejections_on_user_id"
  end

  create_table "representations", force: :cascade do |t|
    t.bigint "resource_id", null: false
    t.text "text"
    t.citext "content_uri"
    t.enum "status", default: "ready_to_review", null: false, enum_name: "representation_status"
    t.bigint "metum_id", null: false
    t.bigint "author_id", null: false
    t.string "content_type", default: "text/plain", null: false
    t.citext "language", null: false
    t.bigint "license_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.integer "ordinality"
    t.index ["author_id"], name: "index_representations_on_author_id"
    t.index ["license_id"], name: "index_representations_on_license_id"
    t.index ["metum_id"], name: "index_representations_on_metum_id"
    t.index ["resource_id"], name: "index_representations_on_resource_id"
    t.index ["status"], name: "index_representations_on_status"
  end

  create_table "resource_group_resources", force: :cascade do |t|
    t.bigint "resource_group_id"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_auto_matched", default: false, null: false
    t.index ["resource_group_id"], name: "index_resource_group_resources_on_resource_group_id"
    t.index ["resource_id", "resource_group_id"], name: "index_resources_resource_group_join", unique: true
    t.index ["resource_id"], name: "index_resource_group_resources_on_resource_id"
  end

  create_table "resource_groups", id: :serial, force: :cascade do |t|
    t.citext "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "organization_id", null: false
    t.boolean "default", default: false
    t.citext "webhook_uri"
    t.string "token"
    t.string "auto_match_host_uris", default: [], null: false, array: true
    t.index ["organization_id", "name"], name: "index_resource_groups_on_organization_id_and_name", unique: true
    t.index ["webhook_uri"], name: "index_resource_groups_on_webhook_uri"
  end

  create_table "resource_links", force: :cascade do |t|
    t.bigint "subject_resource_id", null: false
    t.string "verb", null: false
    t.bigint "object_resource_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["object_resource_id"], name: "index_resource_links_on_object_resource_id"
    t.index ["subject_resource_id", "verb", "object_resource_id"], name: "index_resource_links", unique: true
    t.index ["subject_resource_id"], name: "index_resource_links_on_subject_resource_id"
  end

  create_table "resource_status_checks", force: :cascade do |t|
    t.bigint "resource_id"
    t.string "source_uri", null: false
    t.integer "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_id"], name: "index_resource_status_checks_on_resource_id"
  end

  create_table "resource_webhook_calls", force: :cascade do |t|
    t.bigint "resource_id", null: false
    t.citext "uri", null: false
    t.json "body"
    t.integer "response"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "response_body"
    t.index ["resource_id"], name: "index_resource_webhook_calls_on_resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name", default: "(no title provided)", null: false
    t.enum "resource_type", default: "image", null: false, enum_name: "resource_type"
    t.citext "canonical_id"
    t.citext "source_uri", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "representations_count", default: 0, null: false
    t.boolean "priority_flag", default: false, null: false
    t.string "host_uris", default: [], null: false, array: true
    t.boolean "is_deleted", default: false, null: false
    t.enum "status", default: "active", null: false, enum_name: "resource_status"
    t.string "source_uri_hash"
    t.index ["canonical_id"], name: "index_resources_on_canonical_id"
    t.index ["is_deleted"], name: "index_resources_on_is_deleted"
    t.index ["organization_id", "canonical_id"], name: "index_resources_on_organization_id_and_canonical_id", unique: true
    t.index ["organization_id"], name: "index_resources_on_organization_id"
    t.index ["priority_flag"], name: "index_resources_on_priority_flag", order: :desc
    t.index ["representations_count"], name: "index_resources_on_representations_count"
    t.index ["source_uri", "organization_id"], name: "index_resources_on_source_uri_and_organization_id", unique: true, where: "((source_uri IS NOT NULL) AND (source_uri <> ''::citext))"
    t.index ["source_uri"], name: "index_resources_on_schemaless_source_uri", opclass: :gin_trgm_ops, using: :gin
    t.index ["source_uri"], name: "index_resources_on_source_uri"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.citext "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "first_name"
    t.citext "last_name"
    t.string "authentication_token", null: false
    t.boolean "staff", default: false, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.integer "organizations_count", default: 0
    t.boolean "active", default: true
    t.string "password_digest"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "resources", on_update: :cascade, on_delete: :cascade
  add_foreign_key "assignments", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "auth_tokens", "users"
  add_foreign_key "imports", "organizations"
  add_foreign_key "imports", "users"
  add_foreign_key "invitations", "organizations", on_update: :cascade, on_delete: :cascade
  add_foreign_key "invitations", "users", column: "recipient_user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "invitations", "users", column: "sender_user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "memberships", "organizations", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "meta", "organizations"
  add_foreign_key "organizations", "licenses", column: "default_license_id"
  add_foreign_key "password_resets", "users"
  add_foreign_key "representation_rejections", "representations"
  add_foreign_key "representation_rejections", "users"
  add_foreign_key "representations", "licenses", on_update: :cascade, on_delete: :restrict
  add_foreign_key "representations", "meta", on_update: :cascade, on_delete: :restrict
  add_foreign_key "representations", "resources", on_update: :cascade, on_delete: :restrict
  add_foreign_key "representations", "users", column: "author_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "resource_group_resources", "resource_groups"
  add_foreign_key "resource_group_resources", "resources"
  add_foreign_key "resource_groups", "organizations", on_update: :cascade, on_delete: :cascade
  add_foreign_key "resource_links", "resources", column: "object_resource_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "resource_links", "resources", column: "subject_resource_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "resource_webhook_calls", "resources"
  add_foreign_key "resources", "organizations", on_update: :cascade, on_delete: :restrict
end
