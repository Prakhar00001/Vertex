class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :team, optional: true
  has_many :tasks, -> { order(position: :asc) }, dependent: :destroy

  validates :name, presence: true
  validates :key, presence: true, format: { with: /\A[A-Z0-9]{2,6}\z/, message: "must be 2-6 uppercase letters/digits" },
                  uniqueness: { scope: :organization_id }

  before_validation :upcase_key

  private

  def upcase_key
    self.key = key.upcase if key.present?
  end
end