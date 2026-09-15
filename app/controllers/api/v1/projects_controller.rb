module Api
  module V1
    class ProjectsController < BaseController
      def index
        render json: @current_organization.projects
      end

      def show
        project = @current_organization.projects.find(params[:id])
        render json: project
      end

      def create
        project = @current_organization.projects.build(project_params)
        authorize project
        if project.save
          render json: project, status: :created
        else
          render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def project_params
        params.require(:project).permit(:name, :key, :description, :team_id)
      end
    end
  end
end