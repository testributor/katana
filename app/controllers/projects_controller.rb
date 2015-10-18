class ProjectsController < DashboardController
  include ApplicationHelper

  def show
    ActiveRecord::RecordNotFound unless @project = current_project
  end

  def new
    if client = current_user.github_client
      owner = client.user
      @repos = client.repos.reject do |r|
        r.owner.login != owner.login ||
          r.id.in?(current_user.projects.pluck(:repository_id))
      end.map do |r|
        Project.new(repository_id: r.id, repository_name: r.name,
          repository_owner: owner.login, fork: r.fork?)
      end
    end
  end

  def create
    if project_params[:repository_id].present?  &&
      client = current_user.github_client

      # Retrieve the repo from GitHub to verify the validity
      # of the supplied identifier and create a new Project record.
      repo = client.repo(project_params[:repository_id].to_i)
      project = current_user.projects.
        create(project_params_from_repo(repo))

      if project.persisted?
        hook = GithubWebhookService.
          new(project, github_webhook_url).create_hooks
        project.update_attributes!(webhook_id: hook.id)

        # Create the projects oauth application
        app = Doorkeeper::Application.new(
          :name => project.repository_id,
          :redirect_uri => heroku_url)
        app.owner_id = project.id
        app.owner_type = 'Project'
        app.save

        flash[:notice] =
          "Successfully created '#{project.repository_name}' project."
      else
        flash[:error] = project.errors.full_messages.to_sentence
      end
    end

    redirect_to dashboard_path
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

    redirect_to dashboard_path
  end

  private

  def current_project
    super(:id)
  end

  def project_params
    params.require(:project).permit(:repository_id)
  end

  def project_params_from_repo(repo)
    {
      name: repo.name,
      user: current_user,
      repository_provider: 'github',
      repository_id: repo.id,
      repository_name: repo.name,
      repository_owner: repo.owner.login
    }
  end
end
