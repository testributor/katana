require 'test_helper'

class TestJobTest < ActiveSupport::TestCase
  let(:job) { FactoryGirl.create(:test_job) }

  describe "#total_running_time" do
    it "returns total time when all times exist" do
      times = [
        { started_at: 1.hour.ago, completed_at: 30.minutes.ago },
        { started_at: 1.hour.ago, completed_at: 15.minutes.ago }
      ]
      create_times(times, job)
      job.save!

      job.total_running_time.must_equal 45.minutes
    end

    it "returns total time when completed_at is missing" do
      times = [
        { started_at: 30.minutes.ago, completed_at: nil },
        { started_at: 1.hour.ago, completed_at: 15.minutes.ago },
        { started_at: 2.hours.ago, completed_at: nil }
      ]
      create_times(times, job)
      job.save!

      job.total_running_time.must_equal 2.hours
    end
  end

  private

  def create_times(times, job)
    times.each do |time|
      job.test_job_files.build(
        started_at: time[:started_at], completed_at: time[:completed_at])
    end
  end
end
