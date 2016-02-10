require 'test_helper'

class EmailNotificationsSettingsFeatureTest < Capybara::Rails::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:tracked_branch) do
    FactoryGirl.create(:tracked_branch, project: project,
                      branch_name: "meaningless_feature")
  end

  describe "Notification Settings" do
    before do
      tracked_branch
      login_as owner, scope: :user
      visit notifications_project_settings_path(project)
    end

    it "allows the user to change the default setting for new branches" do
      select "Never", from: "Default setting"
      click_on "Save"
      owner.participation_for_project(project).new_branch_notify_on.
        must_equal BranchNotificationSetting::NOTIFY_ON_MAP.invert["Never"]

      select "Always", from: "Default setting"
      click_on "Save"
      owner.participation_for_project(project).new_branch_notify_on.
        must_equal BranchNotificationSetting::NOTIFY_ON_MAP.invert["Always"]
    end

    it "allows the user to change the setting of each branch" do
      select "Always", from: "meaningless_feature"
      click_on "Save"
      tracked_branch.branch_notification_settings.first.notify_on.
        must_equal BranchNotificationSetting::NOTIFY_ON_MAP.invert["Always"]

      select "On every failure", from: "meaningless_feature"
      click_on "Save"
      tracked_branch.branch_notification_settings.first.notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert["On every failure"])
    end
  end
end
