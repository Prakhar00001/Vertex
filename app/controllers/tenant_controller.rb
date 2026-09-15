class TenantController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization_context

  private

  def set_organization_context
    @current_organization = current_user.organizations.find_by!(slug: params[:org_slug])
    Current.organization = @current_organization
    Current.membership = current_user.memberships.find_by!(organization: @current_organization)
  rescue ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def current_membership
    Current.membership
  end
  helper_method :current_membership
end