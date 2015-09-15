require 'test_helper'

class TestJobFileTest < ActiveSupport::TestCase
  describe "#total_running_time" do
    let(:job_file) { TestJobFile.new }

    it "returns the correct time when completed_at, started_at exist" do
      job_file.started_at = Time.current
      job_file.completed_at = Time.current + 3.minutes

      job_file.total_running_time.must_equal 3.minutes
    end

    it "returns the correct time when only started_at exists" do
      job_file.started_at = Time.current

      job_file.total_running_time.
        must_equal (Time.current - job_file.started_at).round
    end

    it "returns nil when no started_at, completed_at exist" do
      job_file.total_running_time.must_equal nil
    end
  end
end
