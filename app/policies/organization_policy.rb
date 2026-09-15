class OrganizationPolicy < ApplicationPolicy
  def show?
    record.users.include?(user)
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    user == record.owner
  end

  private

  def owner_or_admin?
    membership = record.memberships.find_by(user: user)
    membership&.owner? || membership&.admin?
  end
end