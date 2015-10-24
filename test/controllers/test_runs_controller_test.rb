require 'test_helper'

class TestRunsControllerTest < ActionController::TestCase
  let(:_test_run) { FactoryGirl.create(:test_run) }
  let(:branch) { _test_run.tracked_branch }
  let(:project) { branch.project }

  describe "GET#show" do
    it "returns 200" do
      sign_in :user, project.user
      get :show, { project_id: project.id,
                   branch_id: branch.id, id: _test_run.id}
      assert_response :ok
    end
  end
end
