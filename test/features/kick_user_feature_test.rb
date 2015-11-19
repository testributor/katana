require 'test_helper'

class HomepageFeatureTest < Capybara::Rails::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:member) { FactoryGirl.create(:user) }

  before do
    project.members << member
  end

  describe "when user is the owner" do
    before do
      login_as owner, scope: :user
      visit project_participations_path(project)
    end

    it "shows revoke access button only on members" do
      owner_participation = owner.project_participations.first
      member_participation = member.project_participations.first
      page.wont_have_selector("a[href='#{project_participation_path(project, owner_participation.id)}']")
      page.must_have_selector("a[href='#{project_participation_path(project, member_participation.id)}']")
    end
  end

  describe "when user is not owner" do
    before do
      login_as member, scope: :user
      visit project_participations_path(project)
    end

    it "shows revoke access button only on self" do
      other_member = FactoryGirl.create(:user)
      project.members << other_member
      owner_participation = owner.project_participations.first
      other_member_participation = other_member.project_participations.first
      member_participation = member.project_participations.first
      page.wont_have_selector("a[href='#{project_participation_path(project, owner_participation.id)}']")
      page.wont_have_selector("a[href='#{project_participation_path(project, other_member_participation.id)}']")
      page.must_have_selector("a[href='#{project_participation_path(project, member_participation.id)}']")
    end
  end
end
