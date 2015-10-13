class ProjectFile < ActiveRecord::Base
  belongs_to :project

  validates :contents, :path, presence: true
  validates :path, uniqueness: { scope: :project_id }
end
