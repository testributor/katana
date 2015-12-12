require 'test_helper'

class TrackedBranchTest < ActiveSupport::TestCase
  let(:tracked_branch) { FactoryGirl.create(:tracked_branch) }

  describe "#cleanup_old_runs" do
    it "preserves only OLD_RUNS_LIMIT most recent(by created_at) TestRuns" do
      oldest_test_run = FactoryGirl.create(:testributor_run,
                                          tracked_branch: tracked_branch,
                                          created_at: 3.days.ago)
      FactoryGirl.create_list(:testributor_run,
                              TrackedBranch::OLD_RUNS_LIMIT,
                              tracked_branch: tracked_branch,
                              created_at: Time.now)
      tracked_branch.cleanup_old_runs

      tracked_branch.test_runs.count.must_equal TrackedBranch::OLD_RUNS_LIMIT
      tracked_branch.test_runs.pluck(:id).wont_include oldest_test_run.id
    end

    it "doesn't destroy any run if test_runs.count <= OLD_RUNS_LIMIT" do
      old_count = TrackedBranch::OLD_RUNS_LIMIT - 1
      FactoryGirl.create_list(:testributor_run, old_count,
                              tracked_branch: tracked_branch)
      tracked_branch.cleanup_old_runs

      tracked_branch.test_runs.count.must_equal old_count
    end
  end
end
