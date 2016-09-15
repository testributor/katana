require 'test_helper'
require 'timeout'

class ProjectWizardRepoAccessFlowFeatureTest< Capybara::Rails::TestCase
  let(:user_without_svc_access) { FactoryGirl.create(:user, :without_svc_access) }
  let(:github_user_public_repos) { FactoryGirl.create(:user, :with_github_public_repo_access) }
  let(:user) { FactoryGirl.create(:user) } # with private repo access by default

  describe 'when user has not given any svc access' do
    before do
      login_as user_without_svc_access, scope: :user
    end

    it 'displays a helping text explaining that he is going to be redirected', js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__) do
        visit project_wizard_path(:select_repository)
        help_blocks = page.all('.help-block')
        help_blocks[0].text.must_equal("You will be redirected to authorize public repository access "\
                                      "Note: You can upgrade access to private repositories later")
        help_blocks[1].text.must_equal("You will be redirected to authorize public & private repository access "\
                                      "Note: Bitbucket authorises access to both public and "\
                                      "private repositories without distinction. This is not a Testributor limitation.")
      end
    end
  end

  describe 'when user has given github public repo access' do
    before do
      login_as github_user_public_repos, scope: :user
    end

    it 'displays a helping text explaining that he provided access', js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__) do
        visit project_wizard_path(:select_repository)
        help_blocks = page.all('.help-block')
        help_blocks[0].text.must_equal 'Access to public repositories granted'
        help_blocks[1].text.must_equal("You will be redirected to authorize public & private repository access "\
                                      "Note: Bitbucket authorises access to both public and "\
                                      "private repositories without distinction. This is not a Testributor limitation.")
      end
    end

    it 'displays a button to upgrade access to private repos', js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__) do
        visit project_wizard_path(:select_repository)
        find('label', text: "GITHUB").click
        page.must_have_selector('.private-repo-access .btn')
      end
    end

    it 'does not display private repositories', js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__) do
        visit project_wizard_path(:select_repository)
        find('label', text: "GITHUB").click
        page.must_have_selector('.private-repo-access .btn')
        list_group = page.find('.list-group')
        within list_group do
          page.wont_have_content('PRIVATE')
        end
      end
    end
  end

  describe 'when user has given github private repo access' do
    before do
      login_as user, scope: :user
    end

    it 'does not display any button to upgrade access', js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__), allow_playback_repeats: true do
        visit project_wizard_path(:select_repository)
        find('label', text: "GITHUB").click
        page.must_have_content('Select a GitHub repository:')
        page.wont_have_selector('.private-repo-access .btn')
        page.must_have_content 'ispyropoulos/aroma-kouzinas'
      end
    end

    it 'displays private repositories', js: true do
      VCR.use_cassette (self.class.name + "::" + self.__name__) do
        visit project_wizard_path(:select_repository)
          find('label', text: "GITHUB").click
          page.must_have_content 'ispyropoulos/aroma-kouzinas'
        list_group = page.find('.list-group')
        within list_group do
          page.must_have_content('PRIVATE')
        end
      end
    end
  end
end
