class BareRepositoryManager::TestRunSetupJob < ActiveJob::Base
  queue_as :default

  def perform(test_run_or_id, data)
    test_run =
      if test_run_or_id.is_a?(TestRun)
        test_run_or_id
      else
        TestRun.find(test_run_or_id)
      end

    parsed_data = nil
    begin
      parsed_data = JSON.parse(data)
    rescue
      test_run.setup_error = "Could not parse the worker's setup data"
      test_run.status = TestStatus::ERROR
      test_run.save!
      return
    end

    if parsed_data["error"]
      test_run.setup_error = parsed_data["error"]
      test_run.status = TestStatus::ERROR
      test_run.save!
    else
      test_run.commit_message = parsed_data["subject"]
      test_run.commit_author_name = parsed_data["author_name"]
      test_run.commit_author_email = parsed_data["author_email"]
      test_run.commit_committer_name = parsed_data["commiter_name"]
      test_run.commit_committer_email = parsed_data["commiter_email"]
      test_run.sha_history = parsed_data["sha_history"]
      commit_timestamp =
        begin
          Time.at(parsed_data["committer_date_unix"]).utc
        rescue TypeError
          # This should not only happen if someone tampers with
          # our worker. In this case, he had it coming.
          Time.current.utc
        end
      test_run.commit_timestamp = commit_timestamp

      parsed_data["jobs"].each do |job_data|
        test_run.test_jobs.build(
          job_name: job_data["job_name"],
          command: job_data["command"],
          before: job_data["before"],
          after: job_data["after"])
      end
      Katanomeas.new(test_run).assign_chunk_indexes_to_test_jobs
      test_run.status = TestStatus::QUEUED

      return nil if test_run.db_status_is_cancelled?
      test_run.save!
      Broadcaster.publish(test_run.redis_live_update_resource_key,
        { test_job: {}, test_run: test_run.reload.serialized_run })
    end
  end
end
