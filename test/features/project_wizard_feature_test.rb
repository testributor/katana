require 'test_helper'

class ProjectWizardFeatureTest < Capybara::Rails::TestCase
  let(:user) { FactoryGirl.create(:user) }

  before do
    login_as user, scope: :user
  end

  it "user can't click on disabled(not-completed) steps", js: true do
    visit root_path
    VCR.use_cassette('repos') do
      find('aside').click_on 'Add a project'
      page.must_have_content 'ispyropoulos/katana'
    end
    VCR.use_cassette('branches') do
      click_on "Select branches"
    end

    page.wont_have_content "You need to select a repository first"
    page.must_have_content "Select a repository"
  end

  it "creates a project with correct attributes after successful completion" do
  end
end
