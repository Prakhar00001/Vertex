class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :teams, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase alphanumeric and hyphens" }

  before_validation :generate_slug, on: :create

  def owner
    memberships.find_by(role: "owner")&.user
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end
end