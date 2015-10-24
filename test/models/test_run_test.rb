require 'test_helper'

class TestRunTest < ActiveSupport::TestCase
  let(:_test_run) { FactoryGirl.create(:test_run) }

  describe "#total_running_time" do
    it "returns total time when all times exist" do
      times = [
        { started_at: 1.hour.ago, completed_at: 30.minutes.ago },
        { started_at: 1.hour.ago, completed_at: 15.minutes.ago }
      ]
      create_times(times, _test_run)
      _test_run.save!

      _test_run.total_running_time.must_equal 45.minutes
    end

    it "returns total time when completed_at is missing" do
      times = [
        { started_at: 30.minutes.ago, completed_at: nil },
        { started_at: 1.hour.ago, completed_at: 15.minutes.ago },
        { started_at: 2.hours.ago, completed_at: nil }
      ]
      create_times(times, _test_run)
      _test_run.save!

      _test_run.total_running_time.must_equal 2.hours
    end

    it "returns nil when TestJob doesn't exist" do
      _test_run.total_running_time.must_equal nil
    end

    it "returns nil when completed_at, started_at are missing" do
      times = [
        { started_at: nil, completed_at: nil },
      ]
      create_times(times, _test_run)
      _test_run.save!

      _test_run.total_running_time.must_equal nil
    end
  end

  private

  def create_times(times, _test_run)
    times.each do |time|
      _test_run.test_jobs.build(
        started_at: time[:started_at], completed_at: time[:completed_at])
    end
  end
end
