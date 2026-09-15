class CommentsController < TenantController
  def create
    project = Current.organization.projects.find(params[:project_id])
    task = project.tasks.find(params[:task_id])
    comment = task.comments.build(comment_params.merge(user: current_user))

    if comment.save
      NotificationService.notify_comment(comment: comment, actor: current_user)
      redirect_to tenant_project_task_path(org_slug: Current.organization.slug, project_id: project.id, id: task.id), notice: "Comment added."
    else
      redirect_to tenant_project_task_path(org_slug: Current.organization.slug, project_id: project.id, id: task.id), alert: "Comment cannot be blank."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end