class TaskPolicy < ApplicationPolicy
  def show?
    record.organization.users.include?(user)
  end

  def create?
    record.organization.users.include?(user)
  end

  def update?
    record.organization.users.include?(user)
  end

  def destroy?
    membership = record.organization.memberships.find_by(user: user)
    membership.owner? || membership.admin? || record.creator == user
  end
end