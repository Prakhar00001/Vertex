class MembershipsController < TenantController
  def index
    @memberships = Current.organization.memberships.includes(:user)
    authorize @memberships.first || Membership.new(organization: Current.organization)
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      membership = Current.organization.memberships.build(user: user, role: params[:role] || "member")
      authorize membership
      if membership.save
        redirect_to tenant_memberships_path(org_slug: Current.organization.slug), notice: "Member added."
      else
        redirect_to tenant_memberships_path(org_slug: Current.organization.slug), alert: "Could not add member."
      end
    else
      redirect_to tenant_memberships_path(org_slug: Current.organization.slug), alert: "User with this email not found."
    end
  end

  def update
    membership = Current.organization.memberships.find(params[:id])
    authorize membership
    membership.update(role: params[:role])
    redirect_to tenant_memberships_path(org_slug: Current.organization.slug), notice: "Role modified."
  end

  def destroy
    membership = Current.organization.memberships.find(params[:id])
    authorize membership
    membership.destroy
    redirect_to tenant_memberships_path(org_slug: Current.organization.slug), notice: "Member removed."
  end
end