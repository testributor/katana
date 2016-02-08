require 'test_helper'

class TestJobsIndexFeatureTest < Capybara::Rails::TestCase
  let(:_test_job_failed) do
    FactoryGirl.create(:testributor_job, status: TestStatus::FAILED)
  end
  let(:_test_job_running) do
    FactoryGirl.create(:testributor_job,
      test_run: _test_job_failed.test_run,
      status: TestStatus::RUNNING)
  end
  let(:_test_job_passed) do
    FactoryGirl.create(:testributor_job,
      test_run: _test_job_failed.test_run,
      status: TestStatus::PASSED)
  end
  let(:_test_job_error) do
    FactoryGirl.create(:testributor_job,
      test_run: _test_job_failed.test_run,
      status: TestStatus::ERROR)
  end
  let(:_test_job_queued) do
    FactoryGirl.create(:testributor_job,
      test_run: _test_job_failed.test_run,
      status: TestStatus::QUEUED)
  end
  let(:_test_job_cancelled) do
    FactoryGirl.create(:testributor_job,
      test_run: _test_job_failed.test_run,
      status: TestStatus::CANCELLED)
  end
  let(:_test_run) { _test_job_failed.test_run }
  let(:project) { _test_run.project }
  let(:owner) { project.user }

  before do
    _test_job_passed
    _test_job_error
    _test_job_queued
    _test_job_running
    login_as owner, scope: :user
    visit project_test_run_path(project, _test_run)
  end

  it "displays test jobs with correct statuses and ctas", js: true do
    page.driver.resize_window(1600, 1200)
    job_trs = all("tr[id^='test-job']")
    error = job_trs[0]
    failed = job_trs[1]
    passed = job_trs[2]
    running = job_trs[3]
    queued = job_trs[4]

    error.must_have_content "Error"
    failed.must_have_content "Failed"
    passed.must_have_content "Passed"
    running.must_have_content "Running"
    queued.must_have_content "Queued"

    queued.all(".btn-danger").length.must_equal 0
    running.all(".btn-danger").length.must_equal 0
    failed.find(".btn-primary").must_have_content "Retry"
    error.find(".btn-primary").must_have_content "Retry"
    passed.find(".btn-primary").must_have_content "Retry"
  end

  it 'displays the test run commit message truncated and escaped (fixed bug)' do
    _test_run.update_column(:commit_message, "Addition: Send notification for exceptions in rake tasks through e-mail & Slack")
    visit project_test_run_path(project, _test_run)
    page.must_have_content "Addition: Send notification for exceptions in rake tasks through e-mail & Slack"
  end
end
