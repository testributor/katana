require 'test_helper'

class TestJobsIndexFeatureTest < Capybara::Rails::TestCase
  let(:_test_job_failed) do
    FactoryGirl.create(:test_job, status: TestStatus::FAILED)
  end
  let(:_test_job_running) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::RUNNING)
  end
  let(:_test_job_passed) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::PASSED)
  end
  let(:_test_job_error) do
    FactoryGirl.create(:test_job,
                       test_run: _test_job_failed.test_run,
                       status: TestStatus::ERROR)
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
      _test_job_passed
      _test_job_failed
      _test_job_error
      _test_job_pending
      _test_job_cancelled
      _test_job_running
      login_as owner, scope: :user
      visit project_branch_test_run_path(project,
                                         _test_run.tracked_branch_id,
                                         _test_run)
    end

    it "displays test jobs with correct statuses and ctas", js: true do
      job_trs = all("tr:not(.danger)")
      cancelled = job_trs[1]
      error = job_trs[2]
      failed = job_trs[3]
      passed = job_trs[4]
      running = job_trs[5]
      pending = job_trs[6]

      cancelled.must_have_content "Cancelled"
      error.must_have_content "Error"
      failed.must_have_content "Failed"
      passed.must_have_content "Passed"
      running.must_have_content "Running"
      pending.must_have_content "Pending"

      cancelled.find("input").value.must_equal "retry"
      pending.find("input").value.must_equal "cancel"
      failed.find("input").value.must_equal "retry"
      error.find("input").value.must_equal "retry"
      running.find("input").value.must_equal "cancel"
      passed.find("input").value.must_equal "retry"
    end
  end
end