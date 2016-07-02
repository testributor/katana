require 'test_helper'

class LiveUpdatesTestRunCreationFeatureTest < Capybara::Rails::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run) }
  let(:owner) { _test_run.project.user }
  let(:_test_job) { FactoryGirl.create(:testributor_job, test_run: _test_run) }
  let(:branch_name) { 'master' }
  let(:commit_sha) { 'a3e2de2r' }
  let(:branch_github_response) do
    commit_github_response =
      Sawyer::Resource.new(Sawyer::Agent.new('api.example.com'),
        {
          name: branch_name,
          sha: commit_sha,
          commit: {
            message: 'Some commit messsage',
            html_url: 'Some url',
            author: {
              name: 'Great Author',
              email: 'great@author.com',
              login: 'authorlogin'
            },
            committer: {
              name: 'Great Committer',
              email: 'great@committer.com',
              date: DateTime.current,
              login: 'committerlogin',
              avatar_url: 'http://dummy.url'
            }
          },
            committer: {
              login: 'committerlogin',
              avatar_url: 'http://dummy.url'
          },
            author: {
              login: 'authorlogin'
          }
        }
      )
    GithubRepositoryManager.any_instance.stubs(:sha_history).returns([
      commit_github_response,
      commit_github_response,
      commit_github_response])
  end

  describe 'when a user is registered' do
    before do
      _test_job
      TrackedBranch.any_instance.stubs(:from_github).returns(branch_github_response)
      login_as owner, scope: :user
    end

    it 'does not render test runs of another channel', js: true do
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)

      FactoryGirl.create(:testributor_run)
      page.all('[id^="test-run"]').size.must_equal 1
    end

    it 'does not change the status of other testRuns', js: true do
      _test_run.update_column(:status, TestStatus::PASSED)
      visit project_test_run_path(_test_run.project.id, _test_run.id)

      FactoryGirl.create(:testributor_run, project_id: _test_run.project_id)
      within '.test-run-header' do
        label = page.find('.label-success')
        label.must_have_content 'Build #1 | Passed'
      end
    end
  end
end
