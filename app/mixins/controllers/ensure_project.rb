# Many controllers specify actions that should not be accessed without a project
# being specified (e.g. test_jobs) and non participant users should not visit.
# Those controllers should include this module.
module Controllers::EnsureProject
  def self.included(receiver)
    receiver.before_action :ensure_project_exists!
  end

  private

  # Any controller that expect current_project to exist should inherit from
  # this controller. This before filter ensures that current_project exists.
  def ensure_project_exists!
    raise ActiveRecord::RecordNotFound unless current_project
  end
end
