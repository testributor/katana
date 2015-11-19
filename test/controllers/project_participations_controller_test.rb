require 'test_helper'

class ProjectParticipationsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    project.members << user
  end

  describe "GET#index" do
    before do
      sign_in :user, project.user
    end

    it "lists members but not the current user" do
      get :index, project_id: project.id
      assigns(:participations).map(&:user_id).must_equal [user.id]
    end
  end

  describe "GET#destroy" do
    before do
      request.env["HTTP_REFERER"] = 'back'
      sign_in :user, project.user
    end

    it "allows the owner to remove members" do
      project.members.map(&:id).sort.
        must_equal [project.user_id, user.id].sort
      delete :destroy, project_id: project.id,
        id: user.project_participations.first.id
      project.members.reload.map(&:id).must_equal [project.user_id]
      user.reload # user should not be destroyed
    end
  end
end
