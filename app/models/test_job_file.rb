class TestJobFile < ActiveRecord::Base
  belongs_to :test_job

  validates :test_job, presence: true

  scope :pending, -> { where(status: TestStatus::PENDING) }
  scope :running, -> { where(status: TestStatus::RUNNING) }
  scope :complete, -> { where(status: TestStatus::COMPLETE) }

  # TODO : Replace this with TestJob#css_class
  def css_class
    case status
    when TestStatus::RUNNING
      'warning'
    when TestStatus::COMPLETE
      failed? ? 'danger' : 'success'
    end
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

  # TODO : This is duplicated in TestJob.
  # DRY code
  def status_text
    if status == TestStatus::COMPLETE
      return failed? ? 'Failed' : 'Passed'
    end

    TestStatus::STATUS_MAP[status]
  end

  def failed?
    test_errors > 0 || failures > 0
  end
end
