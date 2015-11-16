class DockerImage < ActiveRecord::Base
  # Disable inheritance
  self.inheritance_column = :_type_disabled
  belongs_to :project_wizard
end
