class Task < ApplicationRecord
  STATUSES = %w[backlog todo in_progress review done].freeze
  PRIORITIES = %w[low medium high urgent].freeze

  belongs_to :organization
  belongs_to :project
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true

  has_many :task_labels, dependent: :destroy
  has_many :labels, through: :task_labels
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy
  has_many_attached :attachments

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_assignee, ->(user_id) { where(assignee_id: user_id) if user_id.present? }
  scope :search_text, ->(query) {
    where("title ILIKE :q OR description ILIKE :q", q: "%#{query}%") if query.present?
  }
end