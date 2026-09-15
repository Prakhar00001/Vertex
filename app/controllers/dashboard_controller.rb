class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @organizations = current_user.organizations
    if params[:org_slug].present?
      @current_org = @organizations.find_by!(slug: params[:org_slug])
      @my_tasks = @current_org.tasks.where(assignee: current_user).order(due_date: :asc).limit(10)
      @recent_activities = @current_org.activity_logs.includes(:user, :trackable).order(created_at: :desc).limit(15)
      render "dashboard/index", layout: "tenant"
    elsif @organizations.any?
      redirect_to tenant_dashboard_path(org_slug: @organizations.first.slug)
    else
      redirect_to new_organization_path
    end
  end
end