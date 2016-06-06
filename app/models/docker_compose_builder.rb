# This class is responsible for building a docker-compose.yml suitable to start
# a worker for a given project. It uses the selected technologies and base image
# along with any custom_yml (as defined in custom_docker_compose_yml column of
# Project) to build the final docker-compose.yml which the user can use to start
# a worker.
class DockerComposeBuilder
  attr_reader :project, :custom_data

  def initialize(project)
    @project = project
    @custom_data = project.custom_docker_compose_yml_as_hash
  end

  # Return the docker-compose.yml contents for a given Doorkeeper::Application
  # (which should belong to @project)
  def docker_compose_yml(oauth_app_id)
    return nil unless oauth_app_id

    return false if project.docker_image.blank?

    attributes_hash = {}

    attributes_hash.merge!(technologies_hash)
    attributes_hash.merge!(base_image_hash(oauth_app_id))
    attributes_hash.merge!(custom_data) # Merge what's left from root keys

    attributes_hash.to_yaml
  end

  private

  # Returns the selected technologies part
  def technologies_hash
    result = {}
    # Add linked images
    project.technologies.each do |technology|
      data = technology.docker_compose_data
      custom_image_data = custom_data.delete(technology.standardized_name)
      image_attributes = {}
      image_attributes["image"] =
        custom_image_data.try(:delete, "image") || technology.hub_image

      custom_environment_image_data = custom_image_data.try(:delete, "environment")
      if data["environment"].present? || custom_environment_image_data.present?
        image_attributes["environment"] = data["environment"].to_h
        if custom_environment_image_data.present? &&
          custom_environment_image_data.is_a?(Hash) # Sanity check on user input
          image_attributes["environment"].merge!(custom_environment_image_data)
        end
      end
      image_attributes.merge!(custom_image_data) if custom_image_data.present? # Merge what's left

      result[technology.standardized_name] = image_attributes
    end

    result
  end

  def custom_base_image_data
    @custom_base_image_data ||=
      custom_data.delete(project.docker_image.standardized_name)
  end

  def base_image_hash(oauth_app_id)
    base_image_attributes = {}
    base_image_attributes["image"] =
      custom_base_image_data.try(:delete, "image") ||
      project.docker_image.hub_image

    base_image_attributes["command"] =
      custom_base_image_data.try(:delete, "command") ||
      "/bin/bash -l get_and_run_testributor.sh"

    base_image_attributes["links"] = base_image_links
    base_image_attributes["environment"] = base_image_environment(oauth_app_id)

    # Merge what's left from base image data
    if custom_base_image_data.present?
      base_image_attributes.merge!(custom_base_image_data)
    end

    base_image_attributes = {
      project.docker_image.standardized_name => base_image_attributes
    }

    base_image_attributes
  end

  def base_image_links
    result = []
    custom_links = custom_base_image_data.try(:delete, "links")

    result |= project.technologies.map do |tech|
      link = tech.standardized_name
      if tech.docker_compose_data["alias"]
        link += ":#{tech.docker_compose_data["alias"]}"
      end

      link
    end

    if custom_links.is_a?(Array) # Sanity check on user input
      result |= custom_links
    end

    result
  end

  def base_image_environment(oauth_app_id)
    oauth_application = project.oauth_applications.find(oauth_app_id)
    result = {
      'APP_ID' => oauth_application.uid,
      'APP_SECRET' => oauth_application.secret,
      'API_URL' => "http://www.testributor.com/api/v1/"
    }

    # Merge any additional base image variables
    custom_environment = custom_base_image_data.try(:delete, "environment")

    if project.docker_image.docker_compose_data["environment"]
      result.merge!(project.docker_image.docker_compose_data["environment"])
    end

    # Sanity check on user input
    result.merge!(custom_environment) if custom_environment.is_a?(Hash)

    result
  end
end
