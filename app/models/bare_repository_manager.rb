# This class implements all GitHub integration related methods.
# This is an adaptee class for RepositoryManager
class BareRepositoryManager
  attr_reader :project

  def initialize(project)
    @project = project

    unless @project.is_a?(Project)
      raise "BareRepositoryProvider needs a Project to be initialized"
    end
  end

  # Adds a new TestRun for the given commit in the current project
  def create_test_run!(params = {})
    test_run = @project.test_runs.new(params)
    test_run.save!

    test_run
  end

  def cleanup_for_removal
    # Nothing to cleanup
  end

  def post_add_repository_setup
    # Nothing to do here
  end

  def set_deploy_key(key, options={})
    # Nothing to do here. We have no way to add ssh keys on generic repos.
  end

  def remove_deploy_key(key_id)
    # Nothing to do here. We have no way to remove ssh keys from generic repos.
  end

  def publish_status_notification(test_run)
    # Nothing to do here.
  end
end
