class AddOldAvgWorkerCommandRunSecondsToTestJobs < ActiveRecord::Migration
  def change
    add_column :test_jobs, :old_avg_worker_command_run_seconds, :decimal,
      precision: 10, scale: 6
  end
end
