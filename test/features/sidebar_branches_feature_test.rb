require 'test_helper'

class SidebarBranchesFeatureTest < Capybara::Rails::TestCase
  let(:tracked_branch) { FactoryGirl.create(:tracked_branch) }
  let(:project) { tracked_branch.project }
  let(:owner) { project.user }

  before do
    project
  end

  it "displays the tracked branches on the sidebar", js: true do
    project.save!

    login_as owner, scope: :user
    visit root_path

    sidebar = find(".sidebar")

    sidebar.click_on project.name

    sidebar.click_on tracked_branch.branch_name
    page.must_have_content "Status"
  end
end
