module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_api_token!
      before_action :set_tenant_context

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from Pundit::NotAuthorizedError, with: :unauthorized

      private

      def authenticate_api_token!
        authenticate_with_http_token do |token, _options|
          @current_user = User.find_by(api_token: token)
        end
        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
      end

      def set_tenant_context
        slug = request.headers["X-Organization-Slug"]
        @current_organization = @current_user.organizations.find_by!(slug: slug)
        Current.user = @current_user
        Current.organization = @current_organization
      end

      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def unauthorized
        render json: { error: "Forbidden: Access denied" }, status: :forbidden
      end
    end
  end
end