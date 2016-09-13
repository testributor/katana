require 'test_helper'

class TestRunActionsFeatureTest < Capybara::Rails::TestCase
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

    describe 'when a user visits the test_runs index' do
      it 'displays the retry action when the run is passed', js: true do
        _test_run.update_column(:status, TestStatus::PASSED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.must_have_content('RETRY')
      end

      it 'displays the retry action when the run is errored', js: true do
        _test_run.update_column(:status, TestStatus::ERROR)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.must_have_content('RETRY')
      end

      it 'displays the retry action when the run is failed', js: true do
        _test_run.update_column(:status, TestStatus::FAILED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.must_have_content('RETRY')
      end

      it 'does not display the retry action when the run is queued', js: true do
        _test_run.update_column(:status, TestStatus::QUEUED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_content('RETRY')
      end

      it 'does not display the retry action when the run is running', js: true do
        _test_run.update_column(:status, TestStatus::RUNNING)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_content('RETRY')
      end

      it 'does not display the retry action when the run is cancelled', js: true do
        _test_run.update_column(:status, TestStatus::CANCELLED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_content('RETRY')
      end

      it 'displays the cancel action', js: true do
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.must_have_content('CANCEL')
      end

      it 'does not display the Cancel action when the run is FAILED', js: true do
        _test_run.update_column(:status, TestStatus::FAILED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_content('CANCEL')
      end

      it 'does not display the Cancel action when the run is PASSED', js: true do
        _test_run.update_column(:status, TestStatus::PASSED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_content('CANCEL')
      end

      it 'does not display the Cancel action when the run is ERROR', js: true do
        _test_run.update_column(:status, TestStatus::ERROR)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_content('CANCEL')
      end

      it 'does not display the Cancel action when the run is CANCELLED', js: true do
        _test_run.update_column(:status, TestStatus::CANCELLED)
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
        page.wont_have_selector('.btn', text: "CANCEL")
      end

      describe "on TestRun#show page" do
        it 'does not display the Cancel action when the run is FAILED', js: true do
          _test_run.update_column(:status, TestStatus::FAILED)
          visit project_test_run_path(
            _test_run.project.id,
            _test_run.id,
            branch: _test_run.tracked_branch.branch_name)
          page.wont_have_content('CANCEL')
        end

        it 'does not display the Cancel action when the run is PASSED', js: true do
          _test_run.update_column(:status, TestStatus::PASSED)
          visit project_test_run_path(
            _test_run.project.id,
            _test_run.id,
            branch: _test_run.tracked_branch.branch_name)
          page.wont_have_content('CANCEL')
        end

        it 'does not display the Cancel action when the run is ERROR', js: true do
          _test_run.update_column(:status, TestStatus::ERROR)
          visit project_test_run_path(
            _test_run.project.id,
            _test_run.id,
            branch: _test_run.tracked_branch.branch_name)
          page.wont_have_content('CANCEL')
        end

        it 'does not display the Cancel action when the run is CANCELLED', js: true do
          _test_run.update_column(:status, TestStatus::CANCELLED)
          visit project_test_run_path(
            _test_run.project.id,
            _test_run.id)
          page.wont_have_selector('.btn', text: "CANCEL")
        end
      end
    end

    describe 'when a user clicks on delete button' do
      before do
        visit project_test_runs_path(
          _test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
      end

      it 'must delete all test_jobs', js: true do
        _test_run.test_jobs.pluck(:id).must_equal [_test_job.id]
        page.wont_have_selector(".disabled.js-remote-submission")
        page.find("#test-run-#{_test_run.id} .btn.btn-danger", text: "CANCEL").click
        wait_for_requests_to_finish
        page.must_have_selector("#test-run-#{_test_run.id}", text: "Cancelled")
        TestRun.cancelled.count.must_equal 1
      end
    end

    describe 'when a user clicks add a new run button' do
      before do
        visit project_test_runs_path(_test_run.project.id,
          branch: _test_run.tracked_branch.branch_name)
      end

      it 'turns all previous queued test_jobs to cancelled', js: true do
        page.must_have_content 'Queued'
        page.find('a[action="create"]').click
        wait_for_requests_to_finish
        _test_run.reload.status.code.must_equal TestStatus::CANCELLED
        _test_run.test_jobs.pluck(:status).uniq.must_equal [TestStatus::CANCELLED]
      end
    end
  end

  describe 'when the user is not registered visiting a public project' do
    before do
      _test_run.project.update_column(:is_private, false)
      _test_job
      TrackedBranch.any_instance.stubs(:from_github).returns(branch_github_response)
    end

    it 'displays the retry action when the run is passed', js: true do
      _test_run.update_column(:status, TestStatus::PASSED)
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.wont_have_content('CANCEL')
    end

    it 'displays the retry action when the run is errored', js: true do
      _test_run.update_column(:status, TestStatus::ERROR)
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.wont_have_content('CANCEL')
    end

    it 'displays the retry action when the run is failed', js: true do
      _test_run.update_column(:status, TestStatus::FAILED)
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.wont_have_content('CANCEL')
    end

    it 'does not display the retry action when the run is queued', js: true do
      _test_run.update_column(:status, TestStatus::QUEUED)
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.wont_have_content('CANCEL')
    end

    it 'does not display the retry action when the run is running', js: true do
      _test_run.update_column(:status, TestStatus::RUNNING)
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.wont_have_content('CANCEL')
    end

    it 'does not display the retry action when the run is cancelled', js: true do
      _test_run.update_column(:status, TestStatus::CANCELLED)
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.all('td .btn.btn-danger', text: "CANCEL").size.must_equal 0
    end

    it 'displays the cancel action', js: true do
      visit project_test_runs_path(
        _test_run.project.id,
        branch: _test_run.tracked_branch.branch_name)
      page.wont_have_content('RETRY')
      page.wont_have_content('CANCEL')
    end
  end
end
