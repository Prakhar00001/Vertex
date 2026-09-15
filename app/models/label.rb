class Label < ApplicationRecord
  belongs_to :organization
  has_many :task_labels, dependent: :destroy
  has_many :tasks, through: :task_labels

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :color_hex, presence: true, format: { with: /\A#(?:[0-9a-fA-F]{3}){1,2}\z/ }
end