class BareRepositoryManager::TestRunSetupJob < ActiveJob::Base
  queue_as :default

  def perform(test_run_or_id, data)
    test_run =
      if test_run_or_id.is_a?(TestRun)
        test_run_or_id
      else
        TestRun.find(test_run_or_id)
      end

    BareRepositoryManager.new(test_run.project).post_setup_test_run(test_run, data)
  end
end
