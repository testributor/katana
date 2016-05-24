# This class implements all GitHub integration related methods.
# This is an adaptee class for RepositoryManager
class BareRepositoryManager
  attr_reader :project, :errors

  def initialize(project)
    @project = project

    unless @project.is_a?(Project)
      raise "BareRepositoryProvider needs a Project to be initialized"
    end
  end

  # Adds a new TestRun for the given commit in the current project
  def create_test_run!(params = {})
    test_run = @project.test_runs.new(params)
    if test_run.save
      return test_run
    else
      @errors = test_run.errors.full_messages.to_a

      return false
    end
  end

  # Complete the setup of the TestRun with the data received from the worker.
  def post_setup_test_run(test_run, data)
    parsed_data = nil
    begin
      parsed_data = JSON.parse(data)
    rescue
      test_run.setup_error = "Could not parse the worker's setup data"
      test_run.status = TestStatus::ERROR
      test_run.save!
      return
    end

    if parsed_data["error"]
      test_run.setup_error = parsed_data["error"]
      test_run.status = TestStatus::ERROR
      test_run.save!
    else
      test_run.commit_message = parsed_data["subject"]
      test_run.commit_author_name = parsed_data["author_name"]
      test_run.commit_author_email = parsed_data["author_email"]
      test_run.commit_committer_name = parsed_data["commiter_name"]
      test_run.commit_committer_email = parsed_data["commiter_email"]
      test_run.sha_history = parsed_data["sha_history"]

      test_run.commit_timestamp =
        Time.at(parsed_data["committer_date_unix"].to_i).utc

      parsed_data["jobs"].each do |job_data|
        test_run.test_jobs.build(
          job_name: job_data["job_name"],
          command: job_data["command"],
          before: job_data["before"],
          after: job_data["after"])
      end
      Katanomeas.new(test_run).assign_chunk_indexes_to_test_jobs
      test_run.status = TestStatus::QUEUED

      return nil if test_run.db_status_is_cancelled?
      test_run.save!
    end
  end

  def schedule_test_run_setup(test_run)
    # Nothing to do. As long as the status is SETUP, it is already scheduled.
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
