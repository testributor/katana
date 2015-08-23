class TestJob < ActiveRecord::Base
  has_many :test_job_files, dependent: :delete_all
  belongs_to :user

  def status_text
    TestStatus::STATUS_MAP[status]
  end

  def css_class
    case status
    when TestStatus::RUNNING
      'warning'
    when TestStatus::COMPLETE
      failed? ? 'danger' : 'success'
    end
  end

  def total_running_time
    completed_at_times = test_job_files.order("completed_at ASC").
      pluck(:completed_at)
    started_at_times = test_job_files.order("started_at ASC").
      pluck(:started_at)
    if completed_at_times.length == completed_at_times.compact
      completed_at_times.last - started_at_times.first
    elsif time_first_job_started = started_at_times.compact.first
      Time.now - time_first_job_started
    end
  end
end
