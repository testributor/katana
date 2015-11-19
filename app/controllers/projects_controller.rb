class ProjectsController < DashboardController
  include ApplicationHelper

  def show
    ActiveRecord::RecordNotFound unless current_project
    @branches = current_project.tracked_branches.
      includes(test_runs: :test_jobs)
  end

  def settings
    ActiveRecord::RecordNotFound unless current_project
  end

  def instructions
  end

  def update
    begin
      current_project.assign_attributes(project_params)
      current_project.technologies = DockerImage.technologies.
        where(id: project_params[:technology_ids])
      current_project.save
      flash[:notice] = "Project successfully updated"
      redirect_to :back
    rescue ActiveRecord::RecordInvalid => invalid
      flash[:alert] = invalid.record.errors.messages.values.join(', ')
      redirect_to :back
    end
  end

  def destroy
    if client = current_user.github_client
      project = current_user.projects.find(params[:id])

      # Project pre-destroy actions
      # ---------------------------

      # Delete the associated Webhook from the GitHub repo,
      # unless still in use in other projects.
      unless Project.where(webhook_id: project.webhook_id).count(:id) > 1
        unless client.remove_hook(project.repository_id, project.webhook_id)
          # TODO Notify admins about the stale Webhook?
        end
      end

      project.destroy!
      # TODO Project post-destroy actions
      # e.g. Kill Amazon workers (Tasks, ECS instances, etc.)

      flash[:notice] =
        "Successfully destroyed '#{project.repository_name}' project."
    end

    redirect_to root_path
  end

  def docker_compose
    send_data current_project.generate_docker_compose_yaml,
      :type => 'text/yml; charset=UTF-8;',
      :disposition => 'attachment; filename=docker-compose.yml'
  end

  private

  def current_project
    super(:id)
  end

  def project_params
    params.require(:project).permit(:docker_image_id, technology_ids: [])
  end
end
