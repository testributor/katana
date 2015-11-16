class CreateDockerImageSelections < ActiveRecord::Migration
  def change
    create_table :technology_selections do |t|
      t.references :project_wizard, index: true
      t.references :project, index: true
      t.references :docker_image, index: true
      t.string :version

      t.timestamps
    end
  end
end
