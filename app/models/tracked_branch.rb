class TrackedBranch < ActiveRecord::Base
  belongs_to :project
  has_many :test_runs, dependent: :destroy

  delegate :status, :total_running_time, :commit_sha, to: :last_run,
    allow_nil: true

  def last_run
    test_runs.sort_by(&:created_at).last
  end

  # TODO : Write tests
  def create_test_run_and_jobs!
    repo_id = project.repository_id
    repo = client.repo(repo_id)
    branch = client.branch(repo.id, repo[:default_branch])
    c =  branch[:commit]
    run = test_runs.create!(
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
    )
    run.build_test_jobs

    run.save!
  end

  private

  def client
    project.user.github_client
  end
end
