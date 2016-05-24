require 'test_helper'

class BareRepoNewTestRunModalFeatureTest < Capybara::Rails::TestCase
  let(:project) do
    FactoryGirl.create(:project, repository_provider: "bare_repo",
                       repository_url: "git@github.com:ispyropoulos/katana")
  end


  before do
    login_as project.user, scope: :user
    visit project_path(project)
  end

  describe 'new build modal' do
    it 'creates a new build with the modal', js: true do
      page.find(".breadcrumb-actions button", text: "Add a Build").click
      page.must_have_selector("#newTestRunModal", visible: true)
      fill_in "Commit SHA", with: "352413"
      click_on "Create"
      wait_for_requests_to_finish
      TestRun.last.commit_sha.must_equal "352413"
    end

    it "flashes validation errors", js: true do
      page.find(".breadcrumb-actions button", text: "Add a Build").click
      page.must_have_selector("#newTestRunModal", visible: true)
      fill_in "Commit SHA", with: ""
      click_on "Create"
      wait_for_requests_to_finish
      page.must_have_text "Commit sha can't be blank"
    end

    it "opens the modal with the 'No builds found' button too", js: true do
      page.find(".panel button", text: "Add a Build").click
      page.must_have_selector("#newTestRunModal", visible: true)
      fill_in "Commit SHA", with: "884455"
      click_on "Create"
      wait_for_requests_to_finish
      TestRun.last.commit_sha.must_equal "884455"
    end
  end
end
