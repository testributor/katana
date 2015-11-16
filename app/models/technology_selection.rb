class TechnologySelection < ActiveRecord::Base
  belongs_to :project_wizard
  belongs_to :project
  belongs_to :technology, -> { where(type: "technology") }, class_name: "DockerImage",
    foreign_key: :docker_image_id
  # TODO: Validate that version attribute matches an available one in docker_image
end
