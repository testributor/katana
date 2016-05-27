class AddCustomDockerComposeYmlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :custom_docker_compose_yml, :text, default: '', null: false
  end
end
