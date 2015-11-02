class TestJob < ActiveRecord::Base
  belongs_to :test_run

  validates :test_run, presence: true

  scope :pending, -> { where(status: TestStatus::PENDING) }
  scope :running, -> { where(status: TestStatus::RUNNING) }
  scope :complete, -> { where(status: TestStatus::COMPLETE) }
  scope :cancelled, -> { where(status: TestStatus::CANCELLED) }

  def status
    TestStatus.new(read_attribute(:status), failed?)
  end

  # Returns the total time it took for a TestJob to run
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

  def failed?
    test_errors > 0 || failures > 0
  end
end
