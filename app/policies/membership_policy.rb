class MembershipPolicy < ApplicationPolicy
  def index?
    owner_or_admin?
  end

  def create?
    owner_or_admin?
  end

  def update?
    return false if record.user == record.organization.owner
    owner_or_admin?
  end

  def destroy?
    return false if record.user == record.organization.owner
    owner_or_admin? || record.user == user
  end

  private

  def owner_or_admin?
    membership = record.organization.memberships.find_by(user: user)
    membership&.owner? || membership&.admin?
  end
end