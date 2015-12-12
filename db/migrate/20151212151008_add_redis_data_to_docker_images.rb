class AddRedisDataToDockerImages < ActiveRecord::Migration
  def change
    docker_image_attributes = {
      public_name: 'Redis 2.6',
      hub_image: 'redis:2.6',
      version: '2.6',
      standardized_name: 'redis',
      description: "Redis is an open source key-value store that functions as a data structure server.",
      type: 'technology',
      docker_compose_data: {
        alias: 'redis',
        documentation: <<-SQL.strip_heredoc
          The hostname for the redis service is 'redis'.
          The redis service listens for connections on port 6379.
        SQL
      }
    }
    DockerImage.create!(docker_image_attributes)

    docker_image_attributes = {
      public_name: 'Redis 2.8',
      hub_image: 'redis:2.8',
      version: '2.8',
      standardized_name: 'redis',
      description: "Redis is an open source key-value store that functions as a data structure server.",
      type: 'technology',
      docker_compose_data: {
        alias: 'redis',
        documentation: <<-SQL.strip_heredoc
          The hostname for the redis service is 'redis'.
          The redis service listens for connections on port 6379.
        SQL
      }
    }
    DockerImage.create!(docker_image_attributes)

    docker_image_attributes = {
      public_name: 'Redis 3.0',
      hub_image: 'redis:3.0',
      version: '3.0',
      standardized_name: 'redis',
      description: "Redis is an open source key-value store that functions as a data structure server.",
      type: 'technology',
      docker_compose_data: {
        alias: 'redis',
        documentation: <<-SQL.strip_heredoc
          The hostname for the redis service is 'redis'.
          The redis service listens for connections on port 6379.
        SQL
      }
    }
    DockerImage.create!(docker_image_attributes)
  end

  def down
    DockerImage.find_by_standardized_name('redis').destroy_all
  end
end
