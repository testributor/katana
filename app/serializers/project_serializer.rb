class ProjectSerializer < ActiveModel::Serializer
  attributes :repository_name, :repository_owner, :github_access_token,
    :build_commands

  has_many :files

  def github_access_token
    object.user.github_access_token
  end

  def files
    object.project_files
  end

  def build_commands
    <<-TEXT
      bundle install
      RAILS_ENV=test rake db:create
      RAILS_ENV=test rake db:reset
    TEXT
  end
end
