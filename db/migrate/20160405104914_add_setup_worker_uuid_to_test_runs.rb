class AddSetupWorkerUuidToTestRuns < ActiveRecord::Migration
  def change
    add_column :test_runs, :setup_worker_uuid, :string
  end
end
