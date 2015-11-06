require 'test_helper'

class TestJobsIndexFeatureTest < Capybara::Rails::TestCase
  let(:_test_job_failed) do
    FactoryGirl.create(:test_job,
                       status: TestStatus::COMPLETE,
                       test_errors: 1)
  end
  let(:_test_job_running) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::RUNNING)
  end
  let(:_test_job_success) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::COMPLETE)
  end
  let(:_test_job_pending) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::PENDING)
  end
  let(:_test_job_cancelled) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::CANCELLED)
  end
  let(:_test_run) { _test_job_failed.test_run }
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }

  describe "when i visit the test run page" do
    before do
      _test_job_failed
      _test_job_success
      _test_job_pending
      _test_job_cancelled
      _test_job_running
      login_as owner, scope: :user
      visit project_branch_test_run_path(project,
                                         _test_run.tracked_branch_id,
                                         _test_run)
    end

    it "displays test jobs with correct statuses and ctas", js: true do
      cancelled = all("tr")[1]
      failed = all("tr")[2]
      success = all("tr")[3]
      running = all("tr")[4]
      pending = all("tr")[5]

      cancelled.must_have_content "Cancelled"
      pending.must_have_content "Pending"
      failed.must_have_content "Failed"
      running.must_have_content "Running"
      success.must_have_content "Passed"

      cancelled.find("input").value.must_equal "retry"
      pending.find("input").value.must_equal "cancel"
      failed.find("input").value.must_equal "retry"
      running.find("input").value.must_equal "cancel"
      success.find("input").value.must_equal "retry"
    end
  end
end
