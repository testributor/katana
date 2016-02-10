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

  describe "when a new participation is created" do
    let(:tracked_branches) do
      FactoryGirl.create_list(:tracked_branch, 3, project: project)
    end

    before { tracked_branches }

    it "creates branch_notification_settings for all branches on the project for this user" do
      project.reload
      participation = ProjectParticipation.new(project: project, user: user)
      participation.save!
      participation.branch_notification_settings.count.must_equal 3
      participation.branch_notification_settings.map(&:tracked_branch_id).sort.
        must_equal tracked_branches.map(&:id).sort
    end
  end
end
