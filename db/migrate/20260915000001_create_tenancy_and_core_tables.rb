class CreateTenancyAndCoreTables < ActiveRecord::Migration[7.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name,         null: false
      t.string :last_name,          null: false
      t.text   :bio
      t.string :api_token,          null: false

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :api_token,            unique: true

    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps null: false
    end
    add_index :organizations, :slug, unique: true

    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.string :role, null: false, default: "member"
      t.timestamps null: false
    end
    add_index :memberships, [:user_id, :organization_id], unique: true
    add_index :memberships, [:organization_id, :role]

    create_table :teams do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.text :description
      t.timestamps null: false
    end
    add_index :teams, [:organization_id, :name], unique: true

    create_table :team_memberships do |t|
      t.references :team, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps null: false
    end
    add_index :team_memberships, [:team_id, :user_id], unique: true

    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :team, null: true, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.string :key, null: false
      t.text :description
      t.timestamps null: false
    end
    add_index :projects, [:organization_id, :key], unique: true

    create_table :labels do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :color_hex, null: false, default: "#6B7280"
      t.timestamps null: false
    end
    add_index :labels, [:organization_id, :name], unique: true

    create_table :tasks do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.references :creator, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :assignee, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "backlog"
      t.string :priority, null: false, default: "medium"
      t.integer :position, null: false, default: 0
      t.date :due_date
      t.timestamps null: false
    end
    add_index :tasks, [:project_id, :status, :position]
    add_index :tasks, [:organization_id, :assignee_id]
    add_index :tasks, [:organization_id, :due_date]

    create_table :task_labels do |t|
      t.references :task, null: false, foreign_key: { on_delete: :cascade }
      t.references :label, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps null: false
    end
    add_index :task_labels, [:task_id, :label_id], unique: true

    create_table :comments do |t|
      t.references :task, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.text :body, null: false
      t.timestamps null: false
    end

    create_table :activity_logs do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :trackable, polymorphic: true, null: false
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps null: false
    end
    add_index :activity_logs, [:organization_id, :created_at]

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :actor, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :notifiable, polymorphic: true, null: false
      t.string :action, null: false
      t.datetime :read_at
      t.timestamps null: false
    end
    add_index :notifications, [:user_id, :read_at]
  end
end