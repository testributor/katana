require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  describe "#become" do
    describe "when user is not admin" do
      let(:user) { FactoryGirl.create(:user, admin: false) }
      let(:other_user) { FactoryGirl.create(:user, admin: false) }
      before { sign_in :user, user }

      it "returns 401" do
        get :become, id: other_user.id

        response.status.must_equal 401
      end
    end

    describe "when user is admin" do
      let(:admin_user) { FactoryGirl.create(:user, admin: true) }
      let(:other_user) { FactoryGirl.create(:user, admin: false) }

      before { sign_in :user, admin_user }

      it "changes the logged user" do
        get :become, id: other_user.id
        response.status.must_equal 302
        session["warden.user.user.key"].first.first.must_equal other_user.id
      end
    end
  end
end
