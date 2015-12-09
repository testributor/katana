require 'test_helper'

class LiveUpdatesControllerTest < ActionController::TestCase
  describe "#subscribe" do
    let(:_test_job) { FactoryGirl.create(:testributor_job) }
    let(:_test_run) { _test_job.test_run }
    let(:project) { _test_run.project }
    let(:owner) { project.user }
    let(:uid) { 'alpharegavgav' }
    let(:resource_id) { "TestRun##{_test_run.id}" }

    before do
      _test_job
      sign_in :user, owner
    end

    it "responds with unprocessable entity when params[:uid] is missing" do
      post :subscribe, { resource_id: resource_id, uid: '' }
      assert_response :unprocessable_entity
    end

    it "responds with unprocessable entity when params[:resource_id] is missing" do
      post :subscribe, { resource_id: '', uid: uid }
      assert_response :unprocessable_entity
    end

    it "responds with unprocessable entity when both params are missing" do
      post :subscribe, { resource_id: '', uid: '' }

      assert_response :unprocessable_entity
    end

    it "subscribes uid when user has permissions" do
      Broadcaster.expects(:subscribe).with(uid, resource_id).once
      post :subscribe, { resource_id: resource_id, uid: uid }

      assert_response :ok
    end

    it "doesn't subscribe uid when user doesn't have permissions" do
      Broadcaster.expects(:subscribe).with(uid, resource_id).never
      post :subscribe, { resource_id: "TestRun#{_test_run.id + 1}", uid: uid }

      assert_response :unprocessable_entity
    end

    it "doesn't allow 'Arbitrary' params[:resource_id]" do
      post :subscribe, { resource_id: 'Arbitrary', uid: uid }

      assert_response :unprocessable_entity
    end

    it "doesn't allow 'TestRun#arbitrary' params[:resource_id]" do
      -> { post :subscribe, { resource_id: 'TestRun#Arbitrary', uid: uid } }.
        must_raise ActiveRecord::RecordNotFound
    end

    it "permits only whitelisted params[:resource_id]" do
      resource_id_combinations = ["Project##{project.id}",
                                  "TestRun##{_test_run.id}",
                                  "TestJob##{_test_job.id}"]

      resource_id_combinations.each do |resource_id|
        post :subscribe, { resource_id: resource_id, uid: uid }
        assert_response :ok
      end
    end
  end
end
