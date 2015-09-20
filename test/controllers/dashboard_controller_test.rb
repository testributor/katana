class DashboardControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { project.user }

  before { project }

  describe "GET#index" do
    it "should prevent not logged users" do
      get :show, project: project.name
      response.status.must_equal 302
      response.redirect_url.must_match /users\/sign_in/
    end

    it "should allow logged users" do
      sign_in :user, user
      get :show, project: project.name
      assert_response :success
    end
  end
end
