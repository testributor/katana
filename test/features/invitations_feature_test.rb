require 'test_helper'

class InvitationsFeatureTest < Capybara::Rails::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:participant) do
    user = FactoryGirl.create(:user)
    user.participating_projects << project

    user
  end
  let(:invitation) do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:user_invitation, user: user, project: project)
  end

  before do
    invitation
  end

  describe "send invitation menu item" do
    it "shows the menu item when user is the owner of the current project" do
      login_as owner, scope: :user
      visit project_settings_participations_path(project)
      page.must_have_selector "a[href='#{new_project_user_invitation_path(project_id: project.to_param)}']"
    end

    it "does not show the menu item when user is not the owner of the current project" do
      login_as participant, scope: :user
      visit project_path(project)
      page.wont_have_selector "a[href='#{new_project_user_invitation_path(project_id: project.to_param)}']"
    end
  end

  it "displays the list of invited users" do
    login_as owner, scope: :user
    visit project_settings_participations_path(project)
    page.must_have_content "Invitations"
    page.must_have_content invitation.email
  end
end
