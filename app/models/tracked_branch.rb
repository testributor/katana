class TrackedBranch < ActiveRecord::Base
  belongs_to :project
  has_many :test_runs, dependent: :destroy

  delegate :status, :total_running_time,
    :started_at, :commit_sha, to: :last_run, allow_nil: true

  def last_run
    test_runs.sort_by(&:created_at).last
  end

  # TODO : Write tests
  def create_test_run_and_jobs!
    repo_id = project.repository_id
    repo = client.repo(repo_id)
    github_branch = client.branch(repo.id, repo[:default_branch])

    run = test_runs.create!(commit_sha: github_branch[:commit][:sha])
    run.build_test_jobs
    run.save!
  end

  private

  def client
    project.user.github_client
  end
end
