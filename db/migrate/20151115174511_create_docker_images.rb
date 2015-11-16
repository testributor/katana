class CreateDockerImages < ActiveRecord::Migration
  def change
    create_table :docker_images do |t|
      t.string :public_name, null: false, default: ''
      t.string :hub_image, null: false, default: ''
      t.string :standardized_name
      t.string :version
      t.text :description, null: false, default: ''
      t.string :type, null: false, default: 'language'
    end

    DockerImage.create!(
      public_name: 'Ruby 2.2', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: "ruby", version: "2.2")

    DockerImage.create!(
      public_name: 'Ruby 2.1', hub_image: 'testributor/base_image',
      type: 'language', standardized_name: "ruby", version: "2.1")

    DockerImage.create!(
      public_name: 'PostgreSQL 9.3', hub_image: 'postgres:9.3',
      type: 'technology', standardized_name: "postgresql", version: "9.3")

    DockerImage.create!(
      public_name: 'PostgreSQL 9.4', hub_image: 'postgres:9.4',
      type: 'technology', standardized_name: "postgresql", version: "9.4")

    DockerImage.create!(
      public_name: 'Redis 3.0', hub_image: 'redis:3.0',
      type: 'technology', standardized_name: 'redis', version: '3.0')
  end
end
