class TasksController < TenantController
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy move]

  def index
    @tasks = @project.tasks.includes(:assignee, :labels)
    @tasks = @tasks.search_text(params[:query]) if params[:query].present?
    @tasks = @tasks.by_priority(params[:priority]) if params[:priority].present?
    @tasks = @tasks.by_assignee(params[:assignee_id]) if params[:assignee_id].present?

    respond_to do |format|
      format.html
      format.json { render json: @tasks }
    end
  end

  def show
    authorize @task
    @comments = @task.comments.includes(:user)
    @comment = Comment.new
  end

  def new
    @task = @project.tasks.build
    authorize @task
  end

  def create
    result = Tasks::TaskCreationService.new(
      project: @project,
      user: current_user,
      params: task_params
    ).call

    if result.success?
      redirect_to project_path(org_slug: Current.organization.slug, id: @project.id), notice: "Task created."
    else
      @task = result.task
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task
    old_assignee_id = @task.assignee_id

    if @task.update(task_params)
      ActivityLogger.log(
        organization: Current.organization,
        user: current_user,
        trackable: @task,
        action: "task_updated",
        metadata: { changes: @task.previous_changes.except("updated_at") }
      )

      if @task.assignee_id.present? && @task.assignee_id != old_assignee_id
        NotificationService.notify_assignment(task: @task, actor: current_user)
      end

      redirect_to project_task_path(org_slug: Current.organization.slug, project_id: @project.id, id: @task.id), notice: "Task updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def move
    authorize @task, :update?
    new_status = params[:status]
    new_position = params[:position].to_i

    if Task::STATUSES.include?(new_status)
      @task.update(status: new_status, position: new_position)
      ActivityLogger.log(
        organization: Current.organization,
        user: current_user,
        trackable: @task,
        action: "task_moved",
        metadata: { status: new_status, position: new_position }
      )
      render json: { success: true }
    else
      render json: { error: "Invalid status" }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    @task.destroy
    redirect_to project_path(org_slug: Current.organization.slug, id: @project.id), notice: "Task deleted."
  end

  private

  def set_project
    @project = Current.organization.projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :assignee_id, label_ids: [], attachments: [])
  end
end