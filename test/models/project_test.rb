require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  let(:user) { FactoryGirl.create(:user, projects_limit: 1) }
  let(:project) { FactoryGirl.create(:project, user: user) }

  describe "project_limit on user" do
    before { project }

    it "won't assign to a user who reached the projects_limit" do
      project2 = FactoryGirl.build(:project, user: user)
      assert_not project2.save
      assert project2.errors.keys.include?(:base)
    end
  end

  describe "invited_users association" do
    let(:invited_user) do
      User.invite!({ email: 'invited_user@example.com'}, project)
    end

    before { invited_user }

    it "returns users with invitations" do
      project.invited_users.must_equal [invited_user]
    end

    describe "after user accepting the invitation" do
      before do
        User.accept_invitation!(:invitation_token => invited_user.raw_invitation_token,
          :password => "12345678")
      end

      it "still returns the invited user" do
        project.reload.invited_users.must_equal [invited_user]
      end
    end
  end
end
