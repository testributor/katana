require 'test_helper'

class PublicRepositoryFeatureTest < Capybara::Rails::TestCase

  describe 'Importing a Github public repository' do
    let(:user) { FactoryGirl.create(:user, projects_limit: 10) }
    let(:repo_name) { 'testributor-github-api-test-user/test-project-1' }

    before do
      login_as user, scope: :user
    end

    it "creates a github project with correct attributes after successful completion", js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__)  do
        visit project_wizard_path(:select_repository)
        page.must_have_content "GITHUB"
        find('label', text: "GITHUB").click
        page.must_have_content repo_name
        click_on repo_name
      end

      wait_for_requests_to_finish
      project = Project.last
      project.repository_provider.must_equal 'github'
      project.repository_name.must_equal 'test-project-1'
      project.repository_owner.must_equal 'testributor-github-api-test-user'
      project.is_private.must_equal false
    end
  end

  describe 'Importing a Bitbucket public repository' do
    let(:bitbucket_user) { FactoryGirl.create(:bitbucket_user, projects_limit: 10) }
    let(:repo_name) { 'testributor-api-test-user/test-repo-1' }

    before do
      login_as bitbucket_user, scope: :user
    end

    it "creates a bitbucket project with correct attributes after successful completion", js: true do
      visit project_wizard_path(:select_repository)
      page.must_have_content "Select a repository provider:"

      VCR.use_cassette (self.class.name + "::" + self.__name__), record: :new_episodes do
        find(".fa-bitbucket").click
        page.must_have_content repo_name
        click_on repo_name
        wait_for_requests_to_finish
      end

      project = Project.last
      project.repository_provider.must_equal 'bitbucket'
      project.repository_name.must_equal 'test-repo-1'
      project.repository_owner.must_equal 'testributor-api-test-user'
      project.is_private.must_equal false
    end
  end

  describe 'visiting a pulbic project/show page' do
    let(:public_project) { FactoryGirl.create(:public_project) }

    it 'does not display track_branch action' do
      visit project_path(public_project.id)
      page.all('.breadcrumb-actions').size.must_equal 0
    end
  end
end
