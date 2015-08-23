class TestJobFile < ActiveRecord::Base
  belongs_to :test_job

  validates :test_job, presence: true

  def css_class
    case status
    when TestStatus::RUNNING
      'warning'
    when TestStatus::COMPLETE
      failed? ? 'danger' : 'success'
    end
  end

  def total_running_time
    return unless started_at
    if completed_at
      completed_at - started_at
    else
      Time.now - started_at
    end
  end

  def text_status
    return TestStatus::STATUS_MAP[status] unless status == TestStatus::COMPLETE
    failed? ? 'Failed' : 'Passed'
  end

  def failed?
    test_errors > 0 || failures > 0
  end
end
