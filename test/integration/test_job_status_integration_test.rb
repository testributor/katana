require 'test_helper'

class TestJobStatusIntegrationTest < ActionDispatch::IntegrationTest
  describe 'when a failed TestJob in a failed TestRun is retried' do
    let(:failed_test_run) { FactoryGirl.create(:testributor_run, :failed) }
    let(:failed_test_jobs) do
      FactoryGirl.create_list(:testributor_job, 10, :failed,
        test_run: failed_test_run)
    end

    # https://trello.com/c/wE1KtJjx
    it 'should update the TestRun statuses to RUNNING' do
      failed_job = failed_test_jobs.first
      failed_test_run.status.code.must_equal TestStatus::FAILED
      failed_job.update(status: TestStatus::QUEUED)
      failed_test_run.reload.status.code.must_equal TestStatus::RUNNING
    end
  end

  describe 'when an errored TestJob in a errored TestRun is retried' do
    let(:errored_test_run) { FactoryGirl.create(:testributor_run, :error) }
    let(:errored_test_jobs) do
      FactoryGirl.create_list(:testributor_job, 10, :error,
        test_run: errored_test_run)
    end

    # https://trello.com/c/wE1KtJjx
    it 'should update the TestRun statuses to RUNNING' do
      errored_job = errored_test_jobs.first
      errored_test_run.status.code.must_equal TestStatus::ERROR
      errored_job.update(status: TestStatus::QUEUED)
      errored_test_run.reload.status.code.must_equal TestStatus::RUNNING
    end
  end

  describe 'when a cancelled TestJob in a cancelled TestRun is retried' do
    let(:cancelled_test_run) { FactoryGirl.create(:testributor_run, :cancelled) }
    let(:cancelled_test_jobs) do
      FactoryGirl.create_list(:testributor_job, 10, :cancelled,
        test_run: cancelled_test_run)
    end

    # https://trello.com/c/wE1KtJjx
    it 'should not update the TestRun status' do
      cancelled_job = cancelled_test_jobs.first
      cancelled_test_run.status.code.must_equal TestStatus::CANCELLED
      cancelled_job.update(status: TestStatus::QUEUED) # We do not allow this via the UI
      cancelled_test_run.reload.status.code.must_equal TestStatus::CANCELLED
    end
  end
end
