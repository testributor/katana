require 'test_helper'

class Api::V1::ProjectsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:application) do
    FactoryGirl.create(:doorkeeper_application, owner: project)
  end
  let(:token) { application.access_tokens.create }
  let(:project_files) do
    FactoryGirl.create_list(:project_file, 2, project: project)
  end

  let(:build_commands) do
    project.project_files.where(path: ProjectFile::BUILD_COMMANDS_PATH).first
  end

  before { project_files }

  describe "GET#current" do
    it "returns the current project with project_files included" do
      get :current, access_token: token.token,
        default: { format: :json }

      result = JSON.parse(response.body)
      files = result["files"]
      files.first["id"].must_equal build_commands.id
      files.first["path"].must_equal ProjectFile::BUILD_COMMANDS_PATH
      files.first["contents"].must_equal build_commands.contents
      files.last["id"].must_equal project_files.last.id
      files.last["path"].must_equal project_files.last.path
      files.last["contents"].must_equal project_files.last.contents

      (%w(repository_name repository_owner github_access_token files) - result.keys).must_be :blank?
    end
  end

  describe "active_workers (ApiController)" do
    it "monitors the active workers" do
      point_in_time = Time.current
      Timecop.freeze(point_in_time) do
        request.env['HTTP_WORKER_UUID'] = '123'
        get :current, access_token: token.token, default: { format: :json }

        project.active_workers.count.must_equal 1

        request.env['HTTP_WORKER_UUID'] = '124'
        get :current, access_token: token.token, default: { format: :json }

        project.active_workers.count.must_equal 2
      end

      # Expire the workers
      Katana::Application.redis.expire "project_#{project.id}_worker_123", 0
      Katana::Application.redis.expire "project_#{project.id}_worker_124", 0

      project.active_workers.count.must_equal 0
    end
  end
end
