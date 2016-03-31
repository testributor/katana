class TechnologySelection < ActiveRecord::Base
  belongs_to :project
  belongs_to :technology, -> { where(type: "technology") }, class_name: "DockerImage",
    foreign_key: :docker_image_id
  # TODO: Validate that version attribute matches an available one in docker_image

  validate :unique_technologies_on_project,
    if: ->{ project_id && docker_image_id }

  private

  def unique_technologies_on_project
    return true unless project && technology

    if project.technologies.
      where(standardized_name: technology.standardized_name).any?

      errors.add(:base, "Technology #{technology.standardized_name} not unique for project")
    end
  end
end
