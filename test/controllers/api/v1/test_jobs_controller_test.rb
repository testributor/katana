require 'test_helper'

class Api::V1::TestJobsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:application) { Doorkeeper::Application.new(owner: project) }
  # ArgumentError: let 'test_run' cannot begin with 'test'. Please use another name.
  # That's what the _ is for :)
  let(:_test_run) do
    FactoryGirl.create(:testributor_run, project: project, status: TestStatus::QUEUED)
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

  describe "PATCH#bind_next_queued" do
    it "returns queued jobs and updates it's status to RUNNING" do
      _test_jobs[0..-2].each{|f| f.update_column(:status, TestStatus::RUNNING) }
      @controller.stub :doorkeeper_token, token do
        patch :bind_next_batch, default: { format: :json }
        result = JSON.parse(response.body)
        result.first["command"].must_equal _test_jobs[-1].command
        _test_jobs[-1].reload.status.code.must_equal TestStatus::RUNNING
      end
    end

    it "does not count incosistent state jobs in workload" do
      terminal_state_test_run =
        FactoryGirl.create(:testributor_run, project: project)

      # Incosistent jobs (non terminal state jobs in terminal state run)
      FactoryGirl.create_list(:testributor_job, 10,
        test_run: terminal_state_test_run, status: TestStatus::QUEUED)

      # Set the TestRun to inconsistent state
      terminal_state_test_run.update_column(:status, TestStatus::PASSED)

      Project.any_instance.stubs(:active_workers).returns([1,2])
      @controller.stub :doorkeeper_token, token do
        patch :bind_next_batch, default: { format: :json }
        result = JSON.parse(response.body)
        result.count.must_equal 2
      end
    end
  end
end
