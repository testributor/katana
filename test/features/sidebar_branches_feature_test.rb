require 'test_helper'

class SidebarBranchesFeatureTest < Capybara::Rails::TestCase
  let(:_test_run) { FactoryGirl.create(:test_run) }
  let(:tracked_branch) { _test_run.tracked_branch }
  let(:project) { tracked_branch.project }
  let(:owner) { project.user }

  before do
    project
  end

  it "displays the tracked branches on the sidebar", js: true do
    project.save!

    login_as owner, scope: :user
    visit root_path

    sidebar = find("aside.left-panel")

    sidebar.click_on project.name

    sidebar.click_on tracked_branch.branch_name
    page.must_have_content "Status"
  end
end
