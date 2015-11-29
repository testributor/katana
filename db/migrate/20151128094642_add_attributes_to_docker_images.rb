class AddAttributesToDockerImages < ActiveRecord::Migration
  def change
    add_column :docker_images, :docker_compose_data, :json, null: false, default: {}

    DockerImage.find_each do |image|
      image.docker_compose_data[:image] = image.hub_image
      image.docker_compose_data[:documentation] = ''
      image.docker_compose_data[:alias] = image.standardized_name
      image.docker_compose_data[:environment] = {}
      image.save!
    end
  end
end
