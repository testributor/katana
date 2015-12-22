class Katanomeas
  # The resulting chunks will have costs +- 50% of this value
  # except for the jobs that have costs already bigger that this value
  CHUNK_COST_SECONDS = 30

  attr_reader :test_run

  def initialize(test_run)
    @test_run = test_run
  end

  def assign_chunk_indexes_to_test_jobs
    if test_run.most_relevant_run
      test_jobs_with_cost = test_run.test_jobs.map do |test_job|
        test_job.set_old_avg_worker_command_run_seconds
        test_job
      end
      chunk(test_jobs_with_cost) # Set the chunk_index on test_jobs
    else
      test_run.test_jobs.each_with_index do |test_job, index|
        test_job.chunk_index = index
      end
    end
  end

  # @param costs [Array<Testributor::TestJob>] and Array of TestJobs with cost
  # predictions already set.
  def chunk(test_jobs)
    return if test_jobs.empty?

    # Reverse sorted costs. E.g. [23,10,4,1]
    # nil old_avg_worker_command_run_seconds means: no prediction
    sorted_test_jobs = test_jobs.
      select(&:old_avg_worker_command_run_seconds).
      sort_by!{ |job| -job.old_avg_worker_command_run_seconds }

    current_chunk_index = 0
    current_chunk_total_cost = 0
    # Populate the chunk
    sorted_test_jobs.each do |test_job|
      cost = test_job.old_avg_worker_command_run_seconds
      if current_chunk_total_cost == 0 # Only for the first element
        test_job.chunk_index = current_chunk_index
        current_chunk_total_cost += cost
      elsif(current_chunk_total_cost + cost - CHUNK_COST_SECONDS).abs <=
        (current_chunk_total_cost - CHUNK_COST_SECONDS).abs
        test_job.chunk_index = current_chunk_index
        current_chunk_total_cost += cost
      else
        current_chunk_index += 1
        test_job.chunk_index = current_chunk_index
        current_chunk_total_cost = cost
      end
    end

    # The current chunk has elements so move to an empty one to add no
    # prediction jobs
    current_chunk_index += 1 if sorted_test_jobs.any?

    # Now put the jobs with no cost prediction on a chunk on their own
    test_jobs.select{|job| job.old_avg_worker_command_run_seconds.nil?}.each do |nil_cost_job|
      nil_cost_job.chunk_index = current_chunk_index
      current_chunk_index += 1
    end
  end
end
