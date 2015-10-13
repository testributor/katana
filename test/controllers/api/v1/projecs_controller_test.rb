class Api::V1::ProjectsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:application) do
    FactoryGirl.create(:doorkeeper_application, owner: project)
  end
  let(:token) { application.access_tokens.create }
  let(:project_files) do
    FactoryGirl.create_list(:project_file, 2, project: project)
  end

  before { project_files }

  describe "GET#current" do
    it "returns the current project with project_files included" do
      get :current, access_token: token.token,
        default: { format: :json }

      result = JSON.parse(response.body)
      files = result["files"]
      files.first["id"].must_equal project_files.first.id
      files.first["path"].must_equal project_files.first.path
      files.first["contents"].must_equal project_files.first.contents
      files.last["id"].must_equal project_files.last.id
      files.last["path"].must_equal project_files.last.path
      files.last["contents"].must_equal project_files.last.contents

      (%w(repository_name repository_owner github_access_token build_commands files) - result.keys).must_be :blank?
    end
  end
end
