class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [:edit, :update, :destroy]

  def index
    @organizations = current_user.organizations
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(org_params)
    if @organization.save
      @organization.memberships.create!(user: current_user, role: "owner")
      redirect_to tenant_dashboard_path(org_slug: @organization.slug), notice: "Workspace initialized."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; authorize @organization; end

  def update
    authorize @organization
    if @organization.update(org_params)
      redirect_to tenant_dashboard_path(org_slug: @organization.slug), notice: "Workspace updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @organization
    @organization.destroy
    redirect_to organizations_path, notice: "Workspace deleted."
  end

  private

  def set_organization
    @organization = current_user.organizations.find_by!(slug: params[:slug])
  end

  def org_params
    params.require(:organization).permit(:name, :slug)
  end
end