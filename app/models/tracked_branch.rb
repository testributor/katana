class TrackedBranch < ActiveRecord::Base
  belongs_to :project
  has_many :test_runs, dependent: :destroy
  # TODO : Write tests for this validation
  validates :branch_name, uniqueness: { scope: :project_id }

  delegate :status, :total_running_time, :commit_sha, to: :last_run,
    allow_nil: true

  def last_run
    test_runs.sort_by(&:created_at).last
  end

  # Build TestRun and TestJobs for the current TrackedBranch
  # Returns nil if branch doesn't exist in github
  # TODO: Write tests
  def build_test_run_and_jobs(options={})
    if (c = options[:head_commit]).present?
      test_run_params = {
        commit_sha: c[:id],
        commit_message: c[:message],
        commit_timestamp: c[:timestamp],
        commit_url: c[:url],
        commit_author_name: c[:author][:name],
        commit_author_email: c[:author][:email],
        commit_author_username: c[:author][:username],
        commit_committer_name: c[:committer][:name],
        commit_committer_email: c[:committer][:email],
        commit_committer_username: c[:committer][:username]
      }
    else
      begin
        c = from_github[:commit]
      rescue Octokit::NotFound
        # We tried to find a branch in github and it wasn't found.
        # TODO: Destroy branch when we can't find it?
        return nil
      end

      test_run_params = {
        commit_sha: c.sha,
        commit_message: c.commit.message,
        commit_timestamp: c.commit.committer.date,
        commit_url: c.html_url,
        commit_author_name: c.commit.author.name,
        commit_author_email: c.commit.author.email,
        commit_author_username: c.author.login,
        commit_committer_name: c.commit.committer.name,
        commit_committer_email: c.commit.committer.email,
        commit_committer_username: c.committer.login
      }
    end

    run = test_runs.build(test_run_params)

    build_test_jobs_success = run.build_test_jobs
    if build_test_jobs_success && build_test_jobs_success != nil
      copy_errors(run.errors)
    end

    build_test_jobs_success
  end

  def from_github
    client.branch(project.repository_id, branch_name)
  end

  private

  # TODO: this is almost the same as ProjectWizard#copy_errors
  # and TestRun#errors. DRY
  def copy_errors(errors)
    errors.to_hash.each do |key, value|
      value.each do |message|
        self.errors.add(key, message)
      end
    end
  end

  def client
    @client ||= project.user.github_client
  end
end
