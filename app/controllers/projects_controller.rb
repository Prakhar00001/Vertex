class ProjectsController < TenantController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Current.organization.projects.all
  end

  def show
    authorize @project
    @tasks = @project.tasks.includes(:assignee, :labels)
    @tasks_by_status = @tasks.group_by(&:status)
    render layout: "tenant"
  end

  def new
    @project = Current.organization.projects.build
    authorize @project
  end

  def create
    @project = Current.organization.projects.build(project_params)
    authorize @project
    if @project.save
      redirect_to tenant_project_path(org_slug: Current.organization.slug, id: @project.id), notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; authorize @project; end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to tenant_project_path(org_slug: Current.organization.slug, id: @project.id), notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy
    redirect_to tenant_projects_path(org_slug: Current.organization.slug), notice: "Project deleted."
  end

  private

  def set_project
    @project = Current.organization.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :key, :description, :team_id)
  end
end