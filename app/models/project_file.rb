class ProjectFile < ActiveRecord::Base
  belongs_to :project

  validates :contents, :path, presence: true
  validates :path, uniqueness: { scope: :project_id }
  before_destroy -> { return false }, if: :testributor_yml?

  def testributor_yml?
    path == TestRun::JOBS_YML_PATH
  end
end
