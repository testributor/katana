class AddJobNameToTestJobs < ActiveRecord::Migration
  def up
    add_column :test_jobs, :job_name, :string
    TestJob.connection.execute <<-SQL
      UPDATE test_jobs SET job_name = command
    SQL
  end

  def down
    remove_column :test_jobs, :job_name
  end
end
