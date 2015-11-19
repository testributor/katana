require 'test_helper'

class UserInvitationTest < ActiveSupport::TestCase
  let(:user) { FactoryGirl.create(:user) }

  describe "uniqueness for email in project scope" do

    it "does not allow a second invitation to the same email on the same project" do
      existing_invitation =  FactoryGirl.create(:user_invitation)
      invitation = FactoryGirl.build(:user_invitation,
        email: existing_invitation.email, project: existing_invitation.project)
      invitation.wont_be :valid?
      invitation.errors[:email].must_equal ["An invitation for this user already exists"]
    end

    it "allows an invitation when no other exist with the same email on the same project" do
      invitation = FactoryGirl.build(:user_invitation)
      invitation.must_be :valid?
      invitation.save.must_equal true
    end
  end

  describe "inviting members" do
    let(:project) { FactoryGirl.create(:project) }
    let(:user) { FactoryGirl.create(:user) }

    before do
      project.members << user
    end

    it "does not allow inviting members" do
      invitation =
        FactoryGirl.build(:user_invitation, user: user, project: project)
      invitation.wont_be :valid?

      invitation.errors[:email].
        must_equal ["User is already a member of this project"]
    end
  end

  describe "token generation" do
    describe "when token already exists" do
      subject { UserInvitation.new(token: "123") }
      it "does not assign a new token before validation" do
        subject.valid?
        subject.token.must_equal '123'
      end
    end

    describe "when token already is empty" do
      subject { UserInvitation.new }
      it "does not assign a new token before validation" do
        subject.token.must_be :blank?
        subject.valid?
        subject.token.wont_be :blank?
      end
    end
  end
end
