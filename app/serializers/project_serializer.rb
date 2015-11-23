class ProjectSerializer < ActiveModel::Serializer
  attributes :repository_name, :repository_owner, :github_access_token

  has_many :files
  has_one :docker_image

  def github_access_token
    object.user.github_access_token
  end

  def files
    object.project_files
  end

  def docker_image
    { name: object.docker_image.standardized_name, version: object.docker_image.version }
  end
end
