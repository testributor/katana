require 'test_helper'

class WebhooksControllerTest < ActionController::TestCase
  let(:tracked_branch) { FactoryGirl.create(:tracked_branch) }
  let(:project) { tracked_branch.project }
  let(:user) { project.user }
  let(:commit_sha) { "HEAD" }
  let(:filename_1) { "test/models/user_test.rb" }
  let(:filename_2) { "test/models/hello_test.rb" }

  before do
    tracked_branch
    project.update_column(:repository_provider, 'github')
    project.reload
  end

  describe "POST#github" do
    describe "delete event" do
      before do
        request.headers['HTTP_X_GITHUB_EVENT'] = 'delete'
        @controller.stubs(:verify_request_from_github!).returns(nil)
        TestRun.any_instance.stubs(:test_file_names).returns(
          [filename_1, filename_2 ])
        post :github,
          { repository: { id: project.repository_id },
            ref_type: 'branch',
            ref: "#{tracked_branch.branch_name}" }
      end

      it "destroys the branch" do
        TrackedBranch.count.must_equal 0
      end
    end

    describe "push event" do
      before do
        request.headers['HTTP_X_GITHUB_EVENT'] = 'push'
        # Successful authorization for github
        @controller.stubs(:verify_request_from_github!).returns(nil)
        TestRun.any_instance.stubs(:test_file_names).returns(
          [filename_1, filename_2 ])

        post :github, { head_commit: { id: commit_sha },
                        repository: { id: project.repository_id },
                        ref: "refs/head/ispyropoulos/#{tracked_branch.branch_name}" }
        @testrun = TestRun.last
      end

      it "creates a test run with correct attributes" do
        @testrun.tracked_branch_id.must_equal tracked_branch.id
        @testrun.commit_sha.must_equal commit_sha
        @testrun.status.code.must_equal TestStatus::PENDING
      end

      it "creates test jobs with correct attributes" do
        first_job = TestJob.first
        last_job = TestJob.last

        first_job.test_run_id.must_equal @testrun.id
        first_job.file_name.must_equal filename_1

        last_job.test_run_id.must_equal @testrun.id
        last_job.file_name.must_equal filename_2
      end

      it "responds with :ok" do
        assert_response :ok
      end
    end
  end
end
