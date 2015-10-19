class GithubWebhookService
  def initialize(project, webhook_url)
    @project = project
    @webhook_url = ENV['GITHUB_WEBHOOK_URL'] || webhook_url
  end

  # Create a Webhook on the same GitHub repo for communicating
  # various events to our server and store its id with the Project.
  #
  # We listen for 'push' and 'delete' events
  # https://developer.github.com/webhooks/#events
  #
  # If the Webhook already exists, this step is skipped.
  # https://developer.github.com/v3/repos/hooks/#create-a-hook
  def create_hooks
    begin
      hook = github_client.create_hook(
        @project.repository_id, 'web',
        {
          secret: ENV['GITHUB_WEBHOOK_SECRET'],
          url: webhook_url, content_type: 'json'
        }, events: %w(push delete))
    rescue Octokit::UnprocessableEntity => e
      if e.message =~ /hook already exists/i
        hooks = github_client.hooks(@project.repository_id)
        hook = hooks.select do |h|
          h.config.url == webhook_url && h.events == %w(push delete)
        end.first
      else
        raise e
      end
    end

    hook
  end

  private

  def webhook_url
    @webhook_url
  end

  def github_client
    @github_client ||= @project.user.github_client
  end
end
