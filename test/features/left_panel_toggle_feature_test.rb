require 'test_helper'

class LeftPanelToggleFeatureTest < Capybara::Rails::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }

  before do
    login_as owner, scope: :user
    visit root_path
  end

  it "remembers the state of the left bar navigating to different page", js: true do
    page.wont_have_selector("aside.left-panel.collapsed")
    page.find(".top-head .navbar-toggle").click
    page.must_have_selector("aside.left-panel.collapsed")
    visit root_path
    page.must_have_selector("aside.left-panel.collapsed")
  end
end
