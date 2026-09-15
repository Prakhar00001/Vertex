class ProjectPolicy < ApplicationPolicy
  def index?
    record.first&.organization&.users&.include?(user) || true
  end

  def show?
    record.organization.users.include?(user)
  end

  def create?
    membership&.owner? || membership&.admin?
  end

  def update?
    membership&.owner? || membership&.admin?
  end

  def destroy?
    membership&.owner? || membership&.admin?
  end

  private

  def membership
    @membership ||= record.organization.memberships.find_by(user: user)
  end
end