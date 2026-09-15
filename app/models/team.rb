class Team < ApplicationRecord
  belongs_to :organization
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships
  has_many :projects, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :organization_id }
end