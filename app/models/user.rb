class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify
  has_many :created_tasks, class_name: "Task", foreign_key: :creator_id, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_one_attached :avatar

  before_validation :generate_api_token, on: :create

  validates :first_name, :last_name, presence: true
  validates :api_token, presence: true, uniqueness: true

  def name
    "#{first_name} #{last_name}".strip
  end

  def role_in(organization)
    memberships.find_by(organization: organization)&.role
  end

  private

  def generate_api_token
    self.api_token ||= SecureRandom.hex(32)
  end
end