class AddNodeDockerImage < ActiveRecord::Migration
  def up
    DockerImage.create!(public_name: "Node 5.10",
                    hub_image: "testributor/node_image:5.10",
                    standardized_name: "node",
                    version: "5.10.1",
                    description: "Node.js is a JavaScript-based platform for server-side and networking applications.",
                    type: "language",
                    docker_compose_data: {
                      environment: {
                        GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
                      }
                    })

    DockerImage.create!(public_name: "Mongo 3.2.5",
                    hub_image: "mongo:3.2.5",
                    standardized_name: "mongo",
                    version: "3.2.5",
                    description: "MongoDB document databases provide high availability and easy scalability.",
                    type: "technology",
                    docker_compose_data: {
                      alias: "mongo",
                      documentation: "MongoDB does not require authentication by default, but it can be configured to do so.\n\nThe hostname of the database is 'mongo'."
                    })
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
