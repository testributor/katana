require 'test_helper'

class ProjectParticipationTest < ActiveSupport::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_invitation) do
    FactoryGirl.create(:user_invitation, user: user, project: project)
  end

  before do
    user_invitation
    project.members << user
  end

  it "removes invitation for user when removing the participation" do
    user.project_participations.first.destroy
    ->{ user_invitation.reload }.must_raise ActiveRecord::RecordNotFound
  end
end
