module Tasks
  class TaskCreationService
    def initialize(project:, user:, params:)
      @project = project
      @organization = project.organization
      @user = user
      @params = params
    end

    def call
      max_position = @project.tasks.where(status: @params[:status] || "backlog").maximum(:position) || 0
      task = @project.tasks.build(@params)
      task.organization = @organization
      task.creator = @user
      task.position = max_position + 1

      if task.save
        ActivityLogger.log(
          organization: @organization,
          user: @user,
          trackable: task,
          action: "task_created",
          metadata: { title: task.title, project_key: @project.key }
        )

        if task.assignee_id.present? && task.assignee_id != @user.id
          NotificationService.notify_assignment(task: task, actor: @user)
        end

        OpenStruct.new(success?: true, task: task, errors: nil)
      else
        OpenStruct.new(success?: false, task: task, errors: task.errors)
      end
    end
  end
end