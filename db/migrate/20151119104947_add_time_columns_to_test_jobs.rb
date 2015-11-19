class AddTimeColumnsToTestJobs < ActiveRecord::Migration
  def change
    change_table :test_jobs do |t|
      t.datetime :sent_at
      t.decimal :worker_in_queue_seconds, precision: 10, scale: 6
      t.decimal :worker_command_run_seconds, precision: 10, scale: 6
      t.datetime :reported_at
    end
  end
end
