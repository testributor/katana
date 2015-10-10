require 'test_helper'

class TrackMasterJobTest < ActiveJob::TestCase
  describe '#perform' do
    before do
      # Repository id must exist in the vcr cassete response
      @project = FactoryGirl.create(:project, repository_id: 42993121)
      User.any_instance.stubs(:github_access_token).
        returns('a37df4cfe72f1310982642bbb9775d3e4c15ed87')
      VCR.use_cassette('github_client') do
        TrackMasterJob.perform_now(@project.id)
      end
    end

    it "creates the initial test run's objects" do
      project = Project.last
      project.tracked_branches.length.must_equal 1
      project.test_jobs.length.must_equal 1
    end

    describe 'when master is already tracked' do
      it 'does not create the initial test if master already tracked' do
        VCR.use_cassette('github_client') do
          TrackMasterJob.perform_now(@project.id)
        end
        project = Project.last
        project.tracked_branches.length.must_equal 1
        project.test_jobs.length.must_equal 1
      end
    end
  end
end
