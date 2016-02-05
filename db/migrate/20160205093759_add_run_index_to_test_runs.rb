class AddRunIndexToTestRuns < ActiveRecord::Migration
  def up
    add_column :test_runs, :run_index, :integer

    TestRun.reset_column_information

    TrackedBranch.includes(:test_runs).each do |tracked_branch|
      tracked_branch.test_runs.sort_by(&:id).each_with_index do |run, index|
        run.update_column(:run_index, index + 1)
      end
    end
  end

  def down
    remove_column :test_runs, :run_index
  end
end
