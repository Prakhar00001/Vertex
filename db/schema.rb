ActiveRecord::Schema[7.1].define(version: 2026_09_15_000002) do
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "trackable_type", null: false
    t.bigint "trackable_id", null: false
    t.string "action", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "created_at"], name: "index_activity_logs_on_organization_id_and_created_at"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_comments_on_task_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "labels", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "color_hex", default: "#6B7280", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_labels_on_organization_id_and_name", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "role"], name: "index_memberships_on_organization_id_and_role"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "actor_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "action", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "team_id"
    t.string "name", null: false
    t.string "key", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "key"], name: "index_projects_on_organization_id_and_key", unique: true
  end

  create_table "task_labels", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "label_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "label_id"], name: "index_task_labels_on_task_id_and_label_id", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "project_id", null: false
    t.bigint "creator_id", null: false
    t.bigint "assignee_id"
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "backlog", null: false
    t.string "priority", default: "medium", null: false
    t.integer "position", default: 0, null: false
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "assignee_id"], name: "index_tasks_on_organization_id_and_assignee_id"
    t.index ["project_id", "status", "position"], name: "index_tasks_on_project_id_and_status_and_position"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_teams_on_organization_id_and_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "bio"
    t.string "api_token", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "organizations", on_delete: :cascade
  add_foreign_key "activity_logs", "users", on_delete: :cascade
  add_foreign_key "comments", "tasks", on_delete: :cascade
  add_foreign_key "comments", "users", on_delete: :cascade
  add_foreign_key "labels", "organizations", on_delete: :cascade
  add_foreign_key "memberships", "organizations", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "notifications", "users", column: "actor_id", on_delete: :cascade
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "projects", "organizations", on_delete: :cascade
  add_foreign_key "projects", "teams", on_delete: :nullify
  add_foreign_key "task_labels", "labels", on_delete: :cascade
  add_foreign_key "task_labels", "tasks", on_delete: :cascade
  add_foreign_key "tasks", "organizations", on_delete: :cascade
  add_foreign_key "tasks", "projects", on_delete: :cascade
  add_foreign_key "tasks", "users", column: "assignee_id", on_delete: :nullify
  add_foreign_key "tasks", "users", column: "creator_id", on_delete: :cascade
  add_foreign_key "team_memberships", "teams", on_delete: :cascade
  add_foreign_key "team_memberships", "users", on_delete: :cascade
  add_foreign_key "teams", "organizations", on_delete: :cascade
end