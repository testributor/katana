require 'test_helper'

class TrackedBranchesControllerTest < ActionController::TestCase
  let(:branch_name) { "master" }
  let(:project)  { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:branch_params) do
    { branch_name: branch_name }.merge(project_id: project.id)
  end
  let(:filename_1) { "test/models/user_test.rb" }
  let(:filename_2) { "test/models/hello_test.rb" }
  let(:commit_sha) { "034df43" }
  let(:branch_github_response) do
    Sawyer::Resource.new(Sawyer::Agent.new('api.example.com'),
      {
        name: branch_name,
        commit: {
          sha: commit_sha,
          commit: {
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
      TrackedBranch.any_instance.stubs(:from_github).
        returns(branch_github_response)
      @controller.stubs(:github_client).returns(Octokit::Client.new)
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
    end

    it "adds errors to flash when tracked_branch.invalid?" do
      # Create a branch with same branch_name so that uniqueness validation
      # is triggered
      project.tracked_branches.create(branch_name: branch_name)
      post :create, branch_params
      flash[:alert].wont_be :empty?
    end

    it "doesn't call build_test_run_and_jobs when tracked_branch.invalid?" do
      TrackedBranch.any_instance.stubs(:invalid?).returns(true)
      TrackedBranch.any_instance.expects(:build_test_run_and_jobs).never
      post :create, branch_params
    end

    it "adds errors to flash when build_test_run_and_jobs returns nil" do
      TrackedBranch.any_instance.stubs(:build_test_run_and_jobs).returns(nil)
      post :create, branch_params
      flash[:alert].must_equal "#{branch_name} doesn't exist anymore on github"
    end

    describe "on success" do
      it "creates tracked branch" do
        post :create, branch_params
        TrackedBranch.last.branch_name.must_equal branch_name
      end

      it "creates a TestRun with correct attributes" do
        post :create, branch_params
        _test_run = TestRun.last

        _test_run.commit_sha.must_equal commit_sha
        _test_run.status.code.must_equal TestStatus::QUEUED
      end

      it "creates TestJobs" do
        post :create, branch_params

        _test_run = TestRun.last

        _test_run.test_jobs.first.command.must_match filename_1
        _test_run.test_jobs.last.command.must_match filename_2
      end

      it "displays flash notice" do
        post :create, branch_params
        flash[:notice].wont_be :empty?
      end
    end
  end
end
