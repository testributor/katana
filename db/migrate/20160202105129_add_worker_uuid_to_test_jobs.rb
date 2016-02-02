class AddWorkerUuidToTestJobs < ActiveRecord::Migration
  def change
    add_column :test_jobs, :worker_uuid, :string
  end
end
