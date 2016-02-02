class InternalTestJobsSerializer < ActiveModel::Serializer
  include Models::HasRunningTime
  include Models::HasStatus
  include Models::HasWorkerTime
  include Rails.application.routes.url_helpers

  attributes :command, :id, :worker_uuid_short, :status_text, :status_css_class, :retry_url,
    :result, :unsuccessful, :total_running_time, :worker_command_run_seconds,
    :avg_worker_command_run_seconds, :sent_at, :chunk_index, :html_class,
    :test_run_id, :job_name

  # We serialise this attribute as seconds since epoch instead of Datetime to
  # allow easier parsing, as this travels via API calls between the server and
  # the workers. This value will eventually return back to the server (untouched)
  # and will be persisted as TestJob#sent_at [Datetime]. This timestamp helps in
  # making further time calculations and reports for the test suites.
  def sent_at_seconds_since_epoch
    Time.current.utc.to_i
  end

  def sent_at
    I18n.l(object.sent_at, format: :short) if object.sent_at.present?
  end

  def retry_url
    project_test_job_retry_path(object.test_run.project, object)
  end

  def test_run_id
    object.test_run_id
  end
end
