class TrackedBranch < ActiveRecord::Base
  belongs_to :project
  has_many :test_runs, dependent: :destroy

  delegate :css_class, :status_text, :status, :total_running_time,
    :started_at, :commit_sha, to: :last_run, allow_nil: true

  def last_run
    test_runs.sort_by(&:created_at).last
  end
end
