class TrackMasterJob < ActiveJob::Base
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    client = project.user.github_client
    repo = client.repo(project.repository_id)
    master = client.branch(repo.id, repo[:default_branch])
    unless TrackedBranch.where(project_id: project.id,
                               branch_name: repo[:default_branch]).any?

      tracked_master = TrackedBranch.create!(project_id: project.id,
                                             branch_name: repo[:default_branch])
      # Create test job for master
      test_run = tracked_master.test_runs.build(
        commit_sha: master[:commit][:sha],
        status: TestStatus::PENDING)
      test_run.build_test_jobs
      test_run.save!
    end
  end
end
