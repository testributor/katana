require 'test_helper'

class TrackedBranchesControllerTest < ActionController::TestCase
  let(:branch_name) { "master" }
  let(:project)  { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:branch_params) do
    { tracked_branch: { branch_name: branch_name } }.
      merge(project_id: project.id)
  end
  let(:filename_1) { "test/models/user_test.rb" }
  let(:filename_2) { "test/models/hello_test.rb" }
  let(:commit_sha) { "034df43" }
  let(:branch_github_response) do
    Sawyer::Resource.new(Sawyer::Agent.new('api.example.com'),
      {
        name: branch_name,
        commit: {
          commit: {
            tree: { sha: commit_sha },
            message: 'Some commit messsage',
            html_url: 'Some url',
            author: {
              name: 'Great Author',
              email: 'great@author.com',
            },
            committer: {
              name: 'Great Committer',
              email: 'great@committer.com',
            }
          },
          author: { login: 'authorlogin' },
          committer: { login: 'committerlogin' }
        }
      }
    )
  end

  describe "POST#create" do
    before do
      project
      @controller.stubs(:fetch_branch).returns(branch_github_response)
      @controller.stubs(:github_client).
        returns(Octokit::Client.new)
      TestRun.any_instance.stubs(:project_file_names).returns(
        [filename_1, filename_2])
      TestRun.any_instance.stubs(:jobs_yml).returns(
        <<-YML
          each:
            pattern: '.*'
            command: 'bin/rake test %{file}'
        YML
      )
      sign_in :user, owner
      post :create, branch_params
    end

    it "creates tracked branch" do
      TrackedBranch.last.branch_name.must_equal branch_name
    end

    it "creates TestJobs" do
      _test_run = TestRun.last

      _test_run.test_jobs.first.command.must_match filename_1
      _test_run.test_jobs.last.command.must_match filename_2
    end

    it "creates a TestRun with correct attributes" do
      _test_run = TestRun.last

      _test_run.commit_sha.must_equal commit_sha
      _test_run.status.code.must_equal TestStatus::PENDING
    end

    it "displays flash notice" do
      flash[:notice].wont_be :empty?
    end
  end
end
