class TestJobSerializer < ActiveModel::Serializer
  attributes :command, :created_at, :id, :cost_prediction,
    :sent_at_seconds_since_epoch

  belongs_to :test_run

  def cost_prediction
    object.old_avg_worker_command_run_seconds
  end

  # We serialise this attribute as seconds since epoch instead of Datetime to
  # allow easier parsing, as this travels via API calls between the server and
  # the workers. This value will eventually return back to the server (untouched)
  # and will be persisted as TestJob#sent_at [Datetime]. This timestamp helps in
  # making further time calculations and reports for the test suites.
  def sent_at_seconds_since_epoch
    Time.current.utc.to_i
  end
end
