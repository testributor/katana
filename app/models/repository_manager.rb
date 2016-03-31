# This is an Adapter class that delegates the various repository specific
# methods to the provider specific Adaptees.
class RepositoryManager
  attr_reader :manager # the adaptee object

  delegate :create_test_run!, :fetch_repos, :fetch_branches,
    :repository_data, :cleanup_for_removal, :post_add_repository_setup,
    :set_deploy_key, :remove_deploy_key, :publish_status_notification,
    to: :manager

  # Must be initialized with a Project
  # @project [Project]
  def initialize(project)
    @manager = case project.repository_provider
               when "github"
                 GithubRepositoryManager.new(project)
               when "bitbucket"
                 BitbucketRepositoryManager.new(project)
               else
                 raise "Unknown repository provider"
               end
  end
end
