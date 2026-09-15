class ActivityLog < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  validates :action, presence: true
end