require 'test_helper'

class DockerComposeBuilderTest < ActiveSupport::TestCase
  let(:project) { FactoryGirl.build(:project) }
  subject { DockerComposeBuilder.new(project) }

  describe "docker_compose_yml" do
    let(:oauth_app) do
      FactoryGirl.create(:doorkeeper_application, owner: project)
    end

    let(:docker_image) do
      FactoryGirl.create(:docker_image, :language,
        standardized_name: "my_base_image",
        hub_image: "testributor/base_image_1",
        docker_compose_data: { "environment" => { "GEM_URL" => "some_url" } }
      )
    end

    before do
      project.technologies = [
        FactoryGirl.create(:docker_image,
          standardized_name: "my_first_service",
          hub_image: "testributor/my_first_service",
          docker_compose_data: { "environment" => { "SOME_VAR" => 23 } }),

        FactoryGirl.create(:docker_image,
          standardized_name: "my_second_service",
          hub_image: "testributor/my_second_service",
          docker_compose_data: { environment: { "MICKEY" => "MOUSE" } })
      ]

      project.docker_image = docker_image
      project.custom_docker_compose_yml = <<-YAML
        some_other_image:
          image: company/some_other_image
        my_base_image:
          links:
            - a_custom_service
          environment:
            SOME_CUSTOM_VARIABLE: 1234
        my_second_service:
          environment:
            MY_VAR: 'my value'

          some_random_key: 313
      YAML
    end

    it "adds the selected technologies, base image and custom_docker_compose_yml" do
      subject.docker_compose_yml(oauth_app.id).must_equal(
<<-YAML
---
my_first_service:
  image: testributor/my_first_service
  environment:
    SOME_VAR: 23
my_second_service:
  image: testributor/my_second_service
  environment:
    MICKEY: MOUSE
    MY_VAR: my value
  some_random_key: 313
my_base_image:
  image: testributor/base_image_1
  command: "/bin/bash -l get_and_run_testributor.sh"
  links:
  - my_first_service
  - my_second_service
  - a_custom_service
  environment:
    APP_ID: #{oauth_app.uid}
    APP_SECRET: #{oauth_app.secret}
    API_URL: http://www.testributor.com/api/v1/
    GEM_URL: some_url
    SOME_CUSTOM_VARIABLE: 1234
some_other_image:
  image: company/some_other_image
YAML
      )
    end

    it "overwrites the base image's command and image" do
      project.custom_docker_compose_yml = <<-YAML
        my_base_image:
          image: "my_own_image"
          command: "my own command"
      YAML
      subject.docker_compose_yml(oauth_app.id).must_equal(
<<-YAML
---
my_first_service:
  image: testributor/my_first_service
  environment:
    SOME_VAR: 23
my_second_service:
  image: testributor/my_second_service
  environment:
    MICKEY: MOUSE
my_base_image:
  image: my_own_image
  command: my own command
  links:
  - my_first_service
  - my_second_service
  environment:
    APP_ID: #{oauth_app.uid}
    APP_SECRET: #{oauth_app.secret}
    API_URL: http://www.testributor.com/api/v1/
    GEM_URL: some_url
YAML
      )
    end

    it "does not use the custom links when they are not in Array format" do
      project.custom_docker_compose_yml = <<-YAML
        my_base_image:
          links: "my own command"
      YAML
      subject.docker_compose_yml(oauth_app.id).must_equal(
<<-YAML
---
my_first_service:
  image: testributor/my_first_service
  environment:
    SOME_VAR: 23
my_second_service:
  image: testributor/my_second_service
  environment:
    MICKEY: MOUSE
my_base_image:
  image: testributor/base_image_1
  command: \"/bin/bash -l get_and_run_testributor.sh\"
  links:
  - my_first_service
  - my_second_service
  environment:
    APP_ID: #{oauth_app.uid}
    APP_SECRET: #{oauth_app.secret}
    API_URL: http://www.testributor.com/api/v1/
    GEM_URL: some_url
YAML
      )
    end
  end
end
