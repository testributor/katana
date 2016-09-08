namespace :scheduler do
  task daily: :environment do
    RakeHelpers::notify_exception { TrackedBranch.cleanup_old_runs }

    # NOTE: If we never get this notification consider moving it to weekly.
    Rake::Task["test_jobs:notify_admins_on_inconsistent_states"].invoke
  end
end
