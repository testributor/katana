namespace :test_jobs do
  task notify_admins_on_inconsistent_states: :environment do
    RakeHelpers::notify_exception {
      if TestJob.joins(:test_run).
        where("test_runs.status NOT IN (?)", [TestStatus::RUNNING, TestStatus::QUEUED]).
        where(status: [TestStatus::RUNNING,TestStatus::QUEUED]).exists?

        AdminNotificationMailer.inconsistent_state_test_jobs_notification.deliver_now
      end
    }
  end
end
