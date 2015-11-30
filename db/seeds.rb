DockerImage.create!(
  public_name: 'Ruby 1.9.3', hub_image: 'testributor/base_image',
  type: 'language', standardized_name: 'ruby', version: '1.9.3',
  docker_compose_data: {
    environment: {
      GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
    }
  })
DockerImage.create!(
  public_name: 'Ruby 2.0.0', hub_image: 'testributor/base_image',
  type: 'language', standardized_name: 'ruby', version: '2.0.0',
  docker_compose_data: {
    environment: {
      GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
    }
  })
DockerImage.create!(
  public_name: 'Ruby 2.1.4', hub_image: 'testributor/base_image',
  type: 'language', standardized_name: 'ruby', version: '2.1.4',
  docker_compose_data: {
    environment: {
      GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
    }
  })
DockerImage.create!(
  public_name: 'Ruby 2.1.5', hub_image: 'testributor/base_image',
  type: 'language', standardized_name: 'ruby', version: '2.1.5',
  docker_compose_data: {
    environment: {
      GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
    }
  })
DockerImage.create!(
  public_name: 'Ruby 2.2.0', hub_image: 'testributor/base_image',
  type: 'language', standardized_name: 'ruby', version: '2.2.0',
  docker_compose_data: {
    environment: {
      GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
    }
  })
DockerImage.create!(
  public_name: 'Ruby 2.2.1', hub_image: 'testributor/base_image',
  type: 'language', standardized_name: 'ruby', version: '2.2.1',
  docker_compose_data: {
    environment: {
      GEM_URL: "https://www.dropbox.com/s/2dst6le86ihre2a/testributor-0.0.0.gem?dl=0"
    }
  })
DockerImage.create!(
  public_name: 'PostgreSQL 9.3', hub_image: 'postgres:9.3',
  type: 'technology', standardized_name: 'postgresql', version: '9.3',
  docker_compose_data: {
    alias: "postgres",
    environment: {
      POSTGRES_USER: "testributor",
      POSTGRES_PASSWORD: "testributor",
    },
    documentation: <<-SQL.strip_heredoc
      The database credentials are:

      - user: "testributor"
      - password: "testributor"

      The hostname of the database is "postgres"
    SQL
  })
DockerImage.create!(
  public_name: 'PostgreSQL 9.4', hub_image: 'postgres:9.4',
  type: 'technology', standardized_name: 'postgresql', version: '9.4',
  docker_compose_data: {
    alias: "postgres",
    environment: {
      POSTGRES_USER: "testributor",
      POSTGRES_PASSWORD: "testributor",
    },
    documentation: <<-SQL.strip_heredoc
      The database credentials are:

      - user: "testributor"
      - password: "testributor"

      The hostname of the database is "postgres"
    SQL
  })

DockerImage.create!(
  public_name: 'MySQL 5.7', hub_image: 'mysql:5.7',
  type: 'technology', standardized_name: 'mysql', version: '5.7',
  docker_compose_data: {
    alias: "mysql",
    environment: {
      MYSQL_ROOT_PASSWORD: "testributor",
      MYSQL_USER: "testributor",
      MYSQL_PASSWORD: "testributor"
    },
    documentation: <<-SQL.strip_heredoc
      The database credentials are:

      - user: "testributor"
      - password: "testributor"

      The hostname of the database is "mysql"
    SQL
  })

DockerImage.create!(
  public_name: 'MySQL 5.6', hub_image: 'mysql:5.6',
  type: 'technology', standardized_name: 'mysql', version: '5.6',
  docker_compose_data: {
    alias: "mysql",
    environment: {
      MYSQL_ROOT_PASSWORD: "testributor",
      MYSQL_USER: "testributor",
      MYSQL_PASSWORD: "testributor"
    },
    documentation: <<-SQL.strip_heredoc
      The database credentials are:

      - user: "testributor"
      - password: "testributor"

      The hostname of the database is "mysql"
    SQL
  })

DockerImage.create!(
  public_name: 'MySQL 5.5', hub_image: 'mysql:5.5',
  type: 'technology', standardized_name: 'mysql', version: '5.5',
  docker_compose_data: {
    alias: "mysql",
    environment: {
      MYSQL_ROOT_PASSWORD: "testributor",
      MYSQL_USER: "testributor",
      MYSQL_PASSWORD: "testributor"
    },
    documentation: <<-SQL.strip_heredoc
      The database credentials are:

      - user: "testributor"
      - password: "testributor"

      The hostname of the database is "mysql"
    SQL
  })
