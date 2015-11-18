require 'test_helper'

class Api::V1::TestJobsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:application) { Doorkeeper::Application.new(owner: project) }
  # ArgumentError: let 'test_run' cannot begin with 'test'. Please use another name.
  # That's what the _ is for :)
  let(:_test_run) do
    FactoryGirl.create(:testributor_run, project: project, status: TestStatus::PENDING)
  end
  let(:_test_jobs) do
    FactoryGirl.create_list(:testributor_job, 4, test_run: _test_run)
  end
  let(:token) do
    token = MiniTest::Mock.new
    token.expect(:application, application)
    token.expect(:update_column, true, [:last_used_at, Time])
    token.expect(:acceptable?, true, [Doorkeeper::OAuth::Scopes])
  end

  before { _test_jobs }

  describe "PATCH#bind_next_pending" do
    it "returns a pending job and updates it's status to RUNNING" do
      _test_jobs[0..-2].each{|f| f.update_column(:status, TestStatus::RUNNING) }
      @controller.stub :doorkeeper_token, token do
        patch :bind_next_batch, default: { format: :json }
        result = JSON.parse(response.body)
        result.first["command"].must_equal _test_jobs[-1].command
        _test_jobs[-1].reload.status.code.must_equal TestStatus::RUNNING
      end
    end
  end
end
