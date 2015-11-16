class AddDockerImageIdToProjectWizardsAndProjects < ActiveRecord::Migration
  def change
    add_column :projects, :docker_image_id, :integer, index: true
    add_column :project_wizards, :docker_image_id, :integer, index: true
  end
end
