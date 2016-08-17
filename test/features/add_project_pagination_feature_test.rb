require 'test_helper'

class AddProjectPaginationFeatureTest < Capybara::Rails::TestCase
  let(:user) { FactoryGirl.create(:user) }

  before do
    login_as user, scope: :user
  end

  describe 'when user has more than one page of projects' do
    before do
      # instead of creating 60 projects we change the number
      # of fetched projects because we already have 11
      GithubRepositoryManager.send(:remove_const, :REPOSITORIES_PER_PAGE)
      GithubRepositoryManager.const_set(:REPOSITORIES_PER_PAGE, 2)
      VCR.use_cassette (self.class.name + "::" + self.__name__), allow_playback_repeats: true, record: :new_episodes do
        visit project_wizard_path(id: :select_repository)
        find(".fa-github").click
        wait_for_requests_to_finish
      end
    end

    after do
      GithubRepositoryManager.send(:remove_const, :REPOSITORIES_PER_PAGE)
      GithubRepositoryManager.const_set(:REPOSITORIES_PER_PAGE, 10)
    end

    it 'displays pagination according to the number of projects', js: true do
      # 1 - 2 -  next
      page.find_all('.pagination li').size.must_equal 4
      page.must_have_content 'ispyropoulos/aroma-kouzinas'
      page.must_have_content 'testributor-github-api-test-user/agent'
      page.find('.pagination li.active').text.must_equal '1'
    end

    describe 'when he is at the second page' do
      it 'displays the correct page options', js: true do
        VCR.use_cassette (self.class.name + "::" + self.__name__), allow_playback_repeats: true,
          record: :new_episodes do
          click_on '2'
          wait_for_requests_to_finish
          page.must_have_content 'testributor-github-api-test-user/test-project-2'
          page.all('.pagination li').size.must_equal 5
          page.find('.pagination li.active').text.must_equal '2'
        end
      end
    end

    describe 'when he is at the last page' do
      it 'displays the correct page options', js: true do
        VCR.use_cassette (self.class.name + "::" + self.__name__), allow_playback_repeats: true,
          record: :new_episodes do
          click_on '3'
          wait_for_requests_to_finish
          page.find('.pagination li.active').text.must_equal '3'
          page.all('.pagination li').size.must_equal 4
        end
      end
    end
  end

  describe 'when users has projects enough for one page' do
    before do
      GithubRepositoryManager.send(:remove_const, :REPOSITORIES_PER_PAGE)
      GithubRepositoryManager.const_set(:REPOSITORIES_PER_PAGE, 30)
      VCR.use_cassette (self.class.name + "::" + self.__name__) do
        visit project_wizard_path(id: :select_repository)
        find(".fa-github").click
        wait_for_requests_to_finish
      end
    end

    after do
      GithubRepositoryManager.send(:remove_const, :REPOSITORIES_PER_PAGE)
      GithubRepositoryManager.const_set(:REPOSITORIES_PER_PAGE, 10)
    end

    it 'does not display any pagination', js: true do
      page.all('.pagination').must_be :empty?
    end
  end
end
