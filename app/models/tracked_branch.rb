class TrackedBranch < ActiveRecord::Base
  belongs_to :project
  has_many :test_jobs, dependent: :destroy

  def last_run
    test_jobs.sort_by(&:created_at).last
  end

  def status_text
    last_run.status_text if last_run
  end

  def status
    last_run.status if last_run
  end
end
