module Api
  module V1
    class OrganizationsController < BaseController
      def index
        render json: @current_user.organizations
      end

      def show
        render json: @current_organization
      end
    end
  end
end