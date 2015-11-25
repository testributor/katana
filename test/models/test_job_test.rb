require 'test_helper'

class TestJobTest < ActiveSupport::TestCase
  subject { TestJob.new }

  describe '#sent_at_seconds_since_epoch=' do
    describe 'when no seconds are passed' do
      it '#sent_at should return nil' do
        subject.sent_at.must_be_nil
      end
    end

    describe 'when some seconds are passed' do
      let(:time_now) { Time.current }
      let(:epoch_seconds) { time_now.to_i }

      before do
        subject.sent_at_seconds_since_epoch = epoch_seconds
      end

      it '#sent_at should return nil' do
        subject.sent_at.to_s.must_equal time_now.to_s
      end
    end
  end

  describe '#total_running_time' do
    describe 'when times not reported yet' do
      it 'should return nil' do
        subject.total_running_time.must_be_nil
      end
    end

    describe 'when times reported' do
      before do
        time_now = Time.current
        subject.sent_at = time_now - 5.minutes
        subject.reported_at = time_now - 2.minutes
        subject.worker_in_queue_seconds = 60
      end

      it 'should return the duration between the reported and started points' do
        # 2 minutes ago - 5 minutes ago - 1 minute
        subject.total_running_time.must_equal 120 # seconds
      end
    end
  end

  describe '#complete_at' do
    before { subject.valid? }

    describe 'when times not reported yet' do
      it 'should return nil' do
        subject.completed_at.must_be_nil
      end
    end

    describe 'when times reported' do
      let(:five_minutes_ago) { 5.minutes.ago }
      before do
        subject.sent_at = five_minutes_ago
        subject.worker_in_queue_seconds = 60
        subject.worker_command_run_seconds = 2.3
        subject.valid?
      end

      it 'should return the duration between the reported and started points' do
        # 5 minutes ago + 1 minute + 2 minutes (rounded)
        subject.completed_at.must_equal (five_minutes_ago + 62.seconds)
      end
    end
  end

  describe '#update_test_run_status' do
    let(:_test_run) { FactoryGirl.create(:testributor_run) }


    describe 'when all testjobs have the same status' do
      it 'updates the test run status based on the test_jobs' do
        FactoryGirl.create_list(:testributor_job, 2, test_run: _test_run)
        [TestStatus::QUEUED, TestStatus::PASSED,
         TestStatus::FAILED, TestStatus::ERROR, TestStatus::CANCELLED].each do |status|
          _test_run.test_jobs.update_all(:status => status)

          _test_run.test_jobs.size.must_equal 2
          _test_run.update_status!
          _test_run.reload.status.code.must_equal status
        end
      end
    end

    describe 'when there are 2 different statuses' do
      it 'updates to running if queued in statuses' do
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::QUEUED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::ERROR)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::ERROR)

        _test_run.update_status!
        _test_run.reload.status.code.must_equal TestStatus::RUNNING
      end

      it 'updates to error if error in statuses and there is no queued' do
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::FAILED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::FAILED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::ERROR)

        _test_run.update_status!
        _test_run.reload.status.code.must_equal TestStatus::ERROR
      end

      it 'updates to fail if fail in statuses and there is no queued or error in statuses' do
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::PASSED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::PASSED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::FAILED)

        _test_run.update_status!
        _test_run.reload.status.code.must_equal TestStatus::FAILED
      end
    end

    describe 'when there are 3 different statuses' do
      it 'updates to running if queued in statuses' do
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::QUEUED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::PASSED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::FAILED)

        _test_run.update_status!
        _test_run.reload.status.code.must_equal TestStatus::RUNNING
      end

      it 'updates to error if error in statuses and there is no queued' do
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::PASSED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::FAILED)
        FactoryGirl.create(:testributor_job, test_run: _test_run, status: TestStatus::ERROR)

        _test_run.update_status!
        _test_run.reload.status.code.must_equal TestStatus::ERROR
      end
    end

    describe 'when there are 4 different statuses' do
      # Normally there should be no cancelled status in test job
      # unless they are all cancelled but in any case eg: race condition
      it 'updates to cancelled if cancelled in statuses' do
        [TestStatus::QUEUED, TestStatus::FAILED,
         TestStatus::ERROR, TestStatus::CANCELLED].each do |status|

          FactoryGirl.create(:testributor_job, test_run: _test_run, status: status)
        end

        _test_run.test_jobs.size.must_equal 4
        _test_run.update_status!
        _test_run.reload.status.code.must_equal 5
      end

      it 'updates to running' do
        [TestStatus::QUEUED, TestStatus::FAILED,
         TestStatus::ERROR, TestStatus::PASSED].each do |status|

          FactoryGirl.create(:testributor_job, test_run: _test_run, status: status)
        end

        _test_run.test_jobs.size.must_equal 4
        _test_run.update_status!
        _test_run.reload.status.code.must_equal 1
      end
    end
  end
end
