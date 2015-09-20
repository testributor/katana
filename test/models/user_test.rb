require 'test_helper'

class UserTest < ActiveSupport::TestCase
  let(:user) { FactoryGirl.create(:user) }

  describe "invited_by association" do
    let(:project) { FactoryGirl.create(:project) }
    let(:invited_user) do
      User.invite!({ email: 'invited_user@example.com'}, project)
    end

    before { invited_user }

    it "returns the project which invited the user" do
      invited_user.invited_by.must_equal project
    end
  end
end
