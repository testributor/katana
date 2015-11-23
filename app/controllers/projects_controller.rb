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
    project = current_user.projects.find(params[:id])

    current_user.github_client.
      remove_hook(project.repository_id, project.webhook_id)

    if project.destroy
      flash[:notice] =
        "Successfully destroyed '#{project.name}' project."
    else
      flash[:alert] =
        "Could not destroy '#{project.name}' project."
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
