require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  let(:persisted_project) { FactoryGirl.create(:project) }
  let(:user) { persisted_project.user }
  let(:unpersisted_project) { FactoryGirl.build(:project, user: user) }
  let(:project_params) { { project: persisted_project.attributes } }

  before do
    persisted_project
    # TODO: Replace this with valid?
    # Run validations so that unpersisted_project has an error
    unpersisted_project.save
    sign_in :user, user
  end

  describe "POST#create" do
    it "displays flash message on error" do
      user.update_column(:projects_limit, 0)
      @controller.stubs(:create_project).returns(unpersisted_project)
      post :create, project_params

      flash[:error].wont_be :empty?
    end

    it "redirects to dashboard_path on error" do
      @controller.stubs(:create_project).returns(unpersisted_project)
      user.update_column(:projects_limit, 1)
      post :create, project_params

      assert_redirected_to dashboard_path
    end

    it "displays flash notice on success" do
      @controller.stubs(:create_project).returns(persisted_project)
      post :create, project_params

      flash[:notice].wont_be :empty?
    end

    it "redirects to dashboard_path on success" do
      @controller.stubs(:create_project).returns(persisted_project)
      post :create, project_params

      assert_redirected_to dashboard_path
    end
  end
end
