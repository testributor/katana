require 'test_helper'

class GithubStatusNotificationServiceIntegrationTest < ActiveSupport::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run, status: 0) }

  describe 'when a test_run is created' do
    it 'it sends a POST request to github' do
      perform_enqueued_jobs do
        VCR.use_cassette (self.class.name + "::" + self.method_name), match_requests_on: [:host, :method] do
          -> { _test_run }.must_raise Octokit::NotFound
        end
      end
    end
  end

  describe 'when a test_run changes status' do
    it 'sends a POST request to github' do
      perform_enqueued_jobs do
        VCR.use_cassette (self.class.name + "::" + self.method_name), match_requests_on: [:host, :method] do
          -> { _test_run.update_attribute(:status, 2) }.must_raise Octokit::NotFound
        end
      end
    end
  end

  describe 'when a failed TestJob in a failed TestRun is retried' do
    let(:failed_test_run) { FactoryGirl.create(:testributor_run, :failed) }
    let(:failed_test_jobs) do
      FactoryGirl.create_list(:testributor_job, 10, :failed,
        test_run: failed_test_run)
    end

    before do
      @failed_test_run = failed_test_jobs.first.test_run
      @failed_job = failed_test_jobs.first
    end

    it 'sends a POST request to github' do
      perform_enqueued_jobs do
        VCR.use_cassette (self.class.name + "::" + self.method_name), match_requests_on: [:host, :method] do
          -> { @failed_job.update(status: TestStatus::QUEUED) }.must_raise Octokit::NotFound
        end
      end
    end
  end
end
