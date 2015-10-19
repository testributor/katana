# Handles all project creation logic.
# - Create a project
# - Create webhooks
# - Create Oauth application
class ProjectCreationService
  include ApplicationHelper

  def initialize(user, repo_id, webhook_url)
    @user = user
    @repo_id = repo_id
    @webhook_url = webhook_url
    # If github_client is missing, something really
    # bad happened. Raise to let us know.
    raise unless @user.github_client.present?
  end

  # Try to build a Project and persist it into DB.
  # @return Project => The newly created project, persisted or not.
  def apply
    # Retrieve the repo from GitHub to verify the validity
    # of the supplied identifier and create a new Project record.
    repo = github_client.repo(@repo_id)

    @project = @user.projects.create(name: repo.name,
                                     user: @user,
                                     repository_provider: 'github',
                                     repository_id: repo.id,
                                     repository_name: repo.name,
                                     repository_owner: repo.owner.login)

    if @project.persisted?
      hook = GithubWebhookService.
        new(@project, @webhook_url).create_hooks
      @project.update_attributes!(webhook_id: hook.id)
      create_application
    end

    @project
  end

  private

  # Create the projects oauth application
  def create_application
    app = Doorkeeper::Application.new(
      name: @project.repository_id,
      redirect_uri: heroku_url)
    app.owner_id = @project.id
    app.owner_type = 'Project'
    app.save

    app
  end

  def github_client
    @user.github_client
  end
end
