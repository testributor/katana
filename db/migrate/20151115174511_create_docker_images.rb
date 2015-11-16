class CreateDockerImages < ActiveRecord::Migration
  def change
    create_table :docker_images do |t|
      t.string :public_name
      t.text :available_versions, array: true, default: []
      t.string :name
      t.string :version
      t.text :description
      t.references :project_wizard, index: true
      t.references :project, index: true
      t.text :command
      t.string :type
    end

    DockerImage.create!(
      public_name: 'Ruby', name: 'ruby',
      type: 'language', available_versions: %w(2.0 2.1 2.2))

    DockerImage.create!(
      public_name: 'PostgreSQL', name: 'postgres',
      type: 'technology', available_versions: %w(9.0 9.1 9.2 9.3 9.4 9.5))

    DockerImage.create!(
      public_name: 'Redis', name: 'redis',
      type: 'technology', available_versions: %w(2.6 2.8 3.0))
  end
end
