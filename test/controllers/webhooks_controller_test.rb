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
    describe "push event" do
      before do
        request.headers['HTTP_X_GITHUB_EVENT'] = 'push'
        # Successful authorization for github
        @controller.stubs(:verify_request_from_github!).returns(nil)
        TestJob.any_instance.stubs(:test_file_names).returns(
          [filename_1, filename_2 ])

        post :github, { head_commit: { id: commit_sha },
                        repository: { id: project.repository_id },
                        ref: "refs/head/ispyropoulos/#{tracked_branch.branch_name}" }
        @testjob = TestJob.last
      end

      it "creates a test job with correct attributes" do
        @testjob.tracked_branch_id.must_equal tracked_branch.id
        @testjob.commit_sha.must_equal commit_sha
        @testjob.status.must_equal 0
      end

      it "creates test job files with correct attributes" do
        first_job_file = TestJobFile.first
        last_job_file = TestJobFile.last

        first_job_file.test_job_id.must_equal @testjob.id
        first_job_file.file_name.must_equal filename_1

        last_job_file.test_job_id.must_equal @testjob.id
        last_job_file.file_name.must_equal filename_2
      end

      it "responds with :ok" do
        assert_response :ok
      end
    end
  end
end
