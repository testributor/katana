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
        must_equal BranchNotificationSetting::NOTIFY_ON_MAP.invert[:never]

      select "Always", from: "Default setting"
      click_on "Save"
      owner.participation_for_project(project).new_branch_notify_on.
        must_equal BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always]
    end

    it "allows the user to change the setting of each branch" do
      select "Always", from: "meaningless_feature"
      click_on "Save"
      tracked_branch.branch_notification_settings.first.notify_on.
        must_equal BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always]

      select "On every failure", from: "meaningless_feature"
      click_on "Save"
      tracked_branch.branch_notification_settings.first.notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:every_failure])
    end

    it "allows the user to change the setting for 'My builds'", js: true do
      participation = owner.project_participations.last
      participation.my_builds_notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always])
      select "Never", from: "My builds"
      click_on "Save"
      participation.reload.my_builds_notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:never])

      select "Always", from: "My builds"
      click_on "Save"
      participation.reload.my_builds_notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always])
    end

    it "allows the user to change the setting for 'Other member builds'" do
      participation = owner.project_participations.last
      participation.others_builds_notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always])
      select "Never", from: "Other members builds"
      click_on "Save"
      participation.reload.others_builds_notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:never])

      select "Always", from: "Other members builds"
      click_on "Save"
      participation.reload.others_builds_notify_on.must_equal(
        BranchNotificationSetting::NOTIFY_ON_MAP.invert[:always])
    end

    describe "when the project's repository_provider is 'bare_repo'" do
      before do
        project.update_columns(repository_provider: "bare_repo",
          repository_url: "git@github.com:jimmykarily/katana")
        visit notifications_project_settings_path(project)
      end

      it "does not show settings based on branches" do
        page.wont_have_text("Existing branches")
        page.wont_have_text("New branches")
        page.wont_have_selector("#project_participation_new_branch_notify_on")
      end
    end
  end
end
