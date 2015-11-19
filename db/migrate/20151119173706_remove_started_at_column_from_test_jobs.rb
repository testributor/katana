class RemoveStartedAtColumnFromTestJobs < ActiveRecord::Migration
  def up
    remove_column :test_jobs, :started_at
  end

  def down
    add_column :test_jobs, :started_at, :datetime
  end
end
