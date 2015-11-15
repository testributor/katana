require 'test_helper'

class TrackMasterJobTest < ActiveJob::TestCase
  describe '#perform' do
    before do
      # Repository id must exist in the vcr cassete response
      @project = FactoryGirl.create(:project, repository_id: 24643354)
      User.any_instance.stubs(:github_access_token).
        returns('878321d52c0b0aa55b84cca76cf3f07bf3937b0f')
      VCR.use_cassette('github_client') do
        TrackMasterJob.perform_now(@project.id)
      end
    end

    it "creates the initial test run's objects" do
      project = Project.last
      project.tracked_branches.length.must_equal 1
      project.test_runs.length.must_equal 1
    end

    describe 'when master is already tracked' do
      it 'does not create the initial test if master already tracked' do
        VCR.use_cassette('github_client') do
          TrackMasterJob.perform_now(@project.id)
        end
        project = Project.last
        project.tracked_branches.length.must_equal 1
        project.test_runs.length.must_equal 1
      end
    end
  end
end
