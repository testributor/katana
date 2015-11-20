class ResetRecordsInDockerImages < ActiveRecord::Migration
  def up
    DockerImage.destroy_all
    DockerImage.create!(
      public_name: 'Ruby 1.9.3', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: 'ruby', version: '1.9.3')
    DockerImage.create!(
      public_name: 'Ruby 2.0.0', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: 'ruby', version: '2.0.0')
    DockerImage.create!(
      public_name: 'Ruby 2.1.4', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: 'ruby', version: '2.1.4')
    DockerImage.create!(
      public_name: 'Ruby 2.1.5', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: 'ruby', version: '2.1.5')
    ruby_image = DockerImage.create!(
      public_name: 'Ruby 2.2.0', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: 'ruby', version: '2.2.0')
    DockerImage.create!(
      public_name: 'Ruby 2.2.1', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: 'ruby', version: '2.2.1')
    DockerImage.create!(
      public_name: 'PostgreSQL 9.3', hub_image: 'postgres:9.3',
      type: 'technology', standardized_name: 'postgresql', version: '9.3')
    DockerImage.create!(
      public_name: 'PostgreSQL 9.4', hub_image: 'postgres:9.4',
      type: 'technology', standardized_name: 'postgresql', version: '9.4')

    TechnologySelection.destroy_all
    ts_array = []
    Project.pluck(:id).each do |id|
      ts_array << { project_id: id, docker_image_id: ruby_image.id }
    end
    TechnologySelection.create!(ts_array)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
