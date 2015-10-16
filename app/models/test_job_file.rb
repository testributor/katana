class TestJobFile < ActiveRecord::Base
  belongs_to :test_job

  validates :test_job, presence: true

  scope :pending, -> { where(status: TestStatus::PENDING) }
  scope :running, -> { where(status: TestStatus::RUNNING) }
  scope :complete, -> { where(status: TestStatus::COMPLETE) }
  scope :cancelled, -> { where(status: TestStatus::CANCELLED) }

  def css_class
    TestStatus.new(status, failed?).css_class
  end

  # Returns the total time it took for a TestJobFile to run
  # If completed_at is not provided, the total time is calculated
  # from the current moment.
  # @return [ActiveSupport::Duration]
  def total_running_time
    return unless started_at
    if completed_at
      (completed_at - started_at).round
    else
      (Time.current - started_at).round
    end
  end

  def status_text
    TestStatus.new(status, failed?).text
  end

  def failed?
    test_errors > 0 || failures > 0
  end
end
