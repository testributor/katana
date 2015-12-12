namespace :scheduler do
  task :daily do
    TrackedBranch.cleanup_old_runs
  end
end
