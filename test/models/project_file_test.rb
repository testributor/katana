require 'test_helper'

class ProjectFileTest < ActiveSupport::TestCase
  let(:user) { FactoryGirl.create(:user, projects_limit: 1) }
  let(:project) { FactoryGirl.create(:project, user: user) }
  let(:file) do
    FactoryGirl.create(:project_file, project: project, path: "some_path")
  end

  describe "validations" do
    it "does not allow empty contents" do
      FactoryGirl.build(:project_file, contents: nil).wont_be :valid?
      FactoryGirl.build(:project_file, contents: '').wont_be :valid?
      FactoryGirl.build(:project_file, contents: 'something').must_be :valid?
    end

    it "does not allow empty path" do
      FactoryGirl.build(:project_file, path: nil).wont_be :valid?
      FactoryGirl.build(:project_file, path: '').wont_be :valid?
      FactoryGirl.build(:project_file, path: 'something').must_be :valid?
    end

    it "does not allow same path in the project scope" do
      file
      new_file =
        FactoryGirl.build(:project_file, project: project, path: "some_path")
      new_file.wont_be :valid?
      new_file.errors[:path].must_equal ["has already been taken"]
    end

    describe "testributor.yml" do
      let(:file_path) { 'testributor.yml' }
      it "does not allow invalid yml contents" do
        contents = "a : ::"
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal false
        file.errors.added?(:contents, :syntax_error).must_equal true
      end

      it "does not allow contents without a key" do
        contents = "#"
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal false
        file.errors.added?(:contents, :no_key_provided).must_equal true
      end

      it "does not allow an 'each' key without a 'pattern'" do
        contents = <<-YAML
          each:
            command: 'blah'
        YAML
        contents = ({'each' => { 'command' => 'blah' }}).to_yaml
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal false
        file.errors.added?(:contents, :each_without_pattern).must_equal true
      end

      it "does not allow an 'each' key without a 'command'" do
        contents = <<-YAML
          each:
            pattern: 'blah'
        YAML
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal false
        file.errors.added?(:contents, :each_without_command).must_equal true
      end

      it "does not allow an 'each' key without inner keys" do
        contents = <<-YAML
          each:
        YAML
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal false
        file.errors.added?(:contents, :each_without_pattern).must_equal true
        file.errors.added?(:contents, :each_without_command).must_equal true
      end

      it "does not allow a custom specified key without a 'command'" do
        contents = <<-YAML
          custom:
            other: 'blah'
        YAML
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal false
        custom_without_command = "custom is missing \"command\" key"
        file.errors.added?(:contents, custom_without_command).must_equal true
      end

      it "allows a custom specified key with a 'command'" do
        contents = <<-YAML
          custom:
            command: 'blah'
        YAML
        file = ProjectFile.new(path: file_path, contents: contents)

        file.valid?.must_equal true
      end

      it "does not allow changing the path of this file" do
        contents = <<-YAML
          custom:
            command: 'blah'
        YAML
        file = ProjectFile.new(path: file_path, contents: contents)
        file.save!
        file.path = "some_other_path"
        file.save.must_equal false
        file.errors[:path].must_equal ["Cannot change path for this file"]
      end
    end
  end

  describe "generate_docker_compose_yaml" do
    let(:project) { FactoryGirl.create(:project) }

    before do
      project.technologies.create(public_name: "Elastic search",
        standardized_name: "elastic_search", version: '1.0.0',
        docker_compose_data: { alias: "elastic", environment: {
          "PASSWORD" => "123" }
        })
      project.oauth_applications.stubs(:find).
        returns(OpenStruct.new(uid: '123', secret: '123'))
    end

    it "uses the standardized name of a docker image as the name in yml" do
      YAML.load(project.generate_docker_compose_yaml('123')).keys.
        include?("elastic_search").must_equal true
    end

    it "adds aliases to linked images" do
      yml = YAML.load(project.generate_docker_compose_yaml('123'))
      yml[project.docker_image.standardized_name]["links"].
        include?("elastic_search:elastic").must_equal true
    end

    it "adds environment variables to technologies" do
      yml = YAML.load(project.generate_docker_compose_yaml('123'))
      yml["elastic_search"]["environment"]["PASSWORD"].must_equal '123'
    end

    it "adds environment variables to base image" do
      base = project.docker_image
      base.docker_compose_data["environment"] = { "BASE_PASS" => "321" }
      base.save!
      yml = YAML.load(project.generate_docker_compose_yaml('123'))
      yml[project.docker_image.standardized_name]["environment"]["BASE_PASS"].
        must_equal '321'
    end
  end

  describe "testributor yaml file" do
    let(:project) { FactoryGirl.create(:project) }
    let(:_testributor_yml) do
      FactoryGirl.create(:project_file, path: ProjectFile::JOBS_YML_PATH,
                        project: project)
    end

    it "does not allow destroying" do
      _testributor_yml.destroy.must_equal false
      _testributor_yml.reload # it won't raise
    end
  end

  describe "build commands file" do
    let(:project) { FactoryGirl.create(:project) }
    let(:build_commands) do
      project.project_files.where(path: ProjectFile::BUILD_COMMANDS_PATH).first!
    end

    it "does not allow destroying" do
      build_commands.destroy.must_equal false
      build_commands.reload # it won't raise
    end

    it "does not allow changing the path" do
      build_commands.path = "some_other_path"
      build_commands.save.must_equal false
      build_commands.errors[:path].must_equal ["Cannot change path for this file"]
    end
  end

  describe "remove_carriege_returns_from_file" do
    let(:project) { FactoryGirl.create(:project) }
    let(:build_commands) do
      project.project_files.where(path: ProjectFile::BUILD_COMMANDS_PATH).first!
    end
    it 'removes carriege return characters before validation' do
      build_commands.contents = "bundle install\r\napt-get install phantomjs"
      build_commands.valid?
      build_commands.contents.must_equal "bundle install\napt-get install phantomjs"
    end
  end
end
