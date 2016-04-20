class AddNodeDockerImage < ActiveRecord::Migration
  def up
    DockerImage.new(public_name: "Node 5.10.1",
                    hub_image: "node:5.10.1",
                    standardized_name: "node",
                    version: "5.10.1",
                    description: "Node.js is a JavaScript-based platform for server-side and networking applications.",
                    type: "language",
                    docker_compose_data: {
                      environment: {
                        GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
                      }
                    })
  end
end
