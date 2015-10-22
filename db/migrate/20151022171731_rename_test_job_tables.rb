class RenameTestJobTables < ActiveRecord::Migration
  def up
    rename_table :test_jobs, :test_runs
    rename_table :test_job_files, :test_jobs

    rename_column :test_jobs, :test_job_id, :test_run_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
