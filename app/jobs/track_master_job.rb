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
      test_job = tracked_master.test_jobs.build(
        commit_sha: master[:commit][:sha],
        status: TestStatus::PENDING)
      test_job.build_test_job_files
      test_job.save!
    end
  end
end
