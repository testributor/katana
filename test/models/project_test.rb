require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  let(:project) { FactoryGirl.build(:project) }
  let(:owner) { project.user }
  let(:new_owner) { FactoryGirl.create(:user) }

  describe "project limit on user validation" do
    it "doesn't get called when user id hasn't changed" do
      owner.update_column(:projects_limit, 2)
      owner.reload
      project.save!
      project.expects(:check_user_limit).never
      project.save!
    end

    it "gets called when user id has changed" do
      owner.update_column(:projects_limit, 2)
      owner.reload
      project.user = new_owner
      project.expects(:check_user_limit).once
      project.save!
    end

    it "gets called when project is created" do
      skip "Write this test"
    end

    it "is valid if projects limit is greater than user's projects" do
      owner.update_column(:projects_limit, 2)
      owner.reload

      project.valid?.must_equal true
    end

    it "is valid if projects limit is equal to user's projects" do
      owner.update_column(:projects_limit, 1)
      owner.reload

      project.valid?.must_equal true
    end

    it "is invalid if projects limit is less than user's projects" do
      owner.update_column(:projects_limit, 0)
      owner.reload

      project.valid?.must_equal false
      project.errors.keys.must_include :base
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
