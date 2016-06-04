class AddNode620Image < ActiveRecord::Migration
  def up
    DockerImage.create!(
      public_name: 'Node 6.2', hub_image: 'testributor/node_image:6.2.0',
      type: 'language', standardized_name: 'node', version: '6.2.0',
      description: 'Node.js is a JavaScript-based platform for server-side and networking applications.',
      docker_compose_data: {
        environment: {
          GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
      }
    })
  end

  def down
    DockerImage.find_by(public_name: "Node 6.2").destroy
  end
end
