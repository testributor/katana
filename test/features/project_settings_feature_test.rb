require 'test_helper'

class ProjectSettingsFeatureTest < Capybara::Rails::TestCase
  describe "when project's repository provider is 'bare_repo'" do
    let(:project) do
      FactoryGirl.create(:project, repository_provider: "bare_repo",
                        repository_url: "git@github.com:ispyropoulos/katana.git")
    end
    let(:owner) { project.user }

    before do
      login_as owner, scope: :user
      visit project_settings_path(project)
    end

    it "lets the user edit the repository_url setting" do
      fill_in "project_repository_url", with: "the_projects_new_home"
      click_on "Save"
      project.reload.repository_url.must_equal "the_projects_new_home"
    end
  end

  describe "when project's repository provider is not 'bare_repo'" do
    let(:project) do
      FactoryGirl.create(:project, repository_provider: "github",
                        repository_url: "git@github.com:ispyropoulos/katana.git")
    end
    let(:owner) { project.user }

    before do
      login_as owner, scope: :user
      visit project_settings_path(project)
    end

    it "doesn't let the user edit the repository_url setting" do
      page.wont_have_selector "#project_repository_ulr"
    end
  end
end
