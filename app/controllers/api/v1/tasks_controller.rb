module Api
  module V1
    class TasksController < BaseController
      def index
        project = Current.organization.projects.find(params[:project_id])
        tasks = project.tasks.includes(:assignee, :labels)
        render json: tasks.as_json(include: { assignee: { only: %i[id email first_name last_name] }, labels: { only: %i[id name color_hex] } })
      end

      def create
        project = Current.organization.projects.find(params[:project_id])
        result = Tasks::TaskCreationService.new(
          project: project,
          user: @current_user,
          params: task_params
        ).call

        if result.success?
          render json: result.task, status: :created
        else
          render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def task_params
        params.require(:task).permit(:title, :description, :status, :priority, :due_date, :assignee_id)
      end
    end
  end
end