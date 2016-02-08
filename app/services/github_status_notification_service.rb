class GithubStatusNotificationService
  include Rails.application.routes.url_helpers
  # https://developer.github.com/v3/repos/statuses/

  def initialize(test_run)
    @test_run = test_run
  end

  def options_for_publish
    # create_status(repo, sha, state, options = {})
    project = @test_run.project
    description = @test_run.status.to_github_description
    options = { context: 'testributor.com',
                target_url: project_test_run_url(project_id: project.id, id: @test_run.id),
                description: description }
    status = @test_run.status.to_github_status

    { repo_id: project.repository_id,
      test_run_commit: @test_run.commit_sha,
      status: status,
      extra_github_options: options }
  end

  def publish
    # POST /repos/:owner/:repo/statuses/:sha
    # http://www.rubydoc.info/github/octokit/octokit.rb/Octokit%2FClient%2FStatuses%3Acreate_status

    client = @test_run.project.user.github_client
    options = options_for_publish
    client.create_status(options[:repo_id], options[:test_run_commit], options[:status], options[:extra_github_options])
  end
end
