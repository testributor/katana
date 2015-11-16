class TestJob < ActiveRecord::Base
  belongs_to :test_run

  validates :test_run, presence: true

  scope :pending, -> { where(status: TestStatus::PENDING) }
  scope :running, -> { where(status: TestStatus::RUNNING) }
  scope :passed, -> { where(status: TestStatus::PASSED) }
  scope :failed, -> { where(status: TestStatus::FAILED) }
  scope :error, -> { where(status: TestStatus::ERROR) }
  scope :cancelled, -> { where(status: TestStatus::CANCELLED) }

  def status
    TestStatus.new(read_attribute(:status))
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
end
