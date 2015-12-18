class Katanomeas
  # The resulting chunks will have costs +- 50% of this value
  # except for the jobs that have costs already bigger that this value
  CHUNK_COST_SECONDS = 30

  attr_reader :test_run

  def initialize(test_run)
    @test_run = test_run
  end

  def assign_chunk_indexes_to_test_jobs
    if (most_relevant_run = test_run.most_relevant_run)
      costs = test_run.test_jobs.map do |test_job|
        [test_job, test_job.most_relevant_job.try(:avg_worker_command_run_seconds)]
      end
      chunk(costs) # Set the chunk_index on test_jobs
    else
      test_run.test_jobs.each_with_index do |test_job, index|
        test_job.chunk_index = index
      end
    end
  end

  # @costs [Array] in the form [[id, cost],[id, cost], ...]
  def chunk(costs)
    return if costs.empty?

    # Reverse sorted costs. E.g. [23,10,4,1]
    # nil means: no prediction
    sorted_costs = costs.select{|c| !c[1].nil? }.sort_by!{|c| -c[1].to_i}
    # Use unassigned_costs to avoid iterating over the rest of the costs in
    # the list if all of them is already assigned to a chunk
    current_chunk_index = 0
    current_chunk_total_cost = 0

    # Populate the chunk
    sorted_costs.each do |cost|
      if current_chunk_total_cost == 0 # Only for the first element
        cost[0].chunk_index = current_chunk_index
        current_chunk_total_cost += cost[1]
      elsif(current_chunk_total_cost + cost[1] - CHUNK_COST_SECONDS).abs <=
        (current_chunk_total_cost - CHUNK_COST_SECONDS).abs
        cost[0].chunk_index = current_chunk_index
        current_chunk_total_cost += cost[1]
      else
        current_chunk_index += 1
        cost[0].chunk_index = current_chunk_index
        current_chunk_total_cost = cost[1]
      end
    end

    # The current chunk has elements so move to an empty one to add no
    # prediction jobs
    current_chunk_index += 1 if sorted_costs.any?

    # Now put the jobs with no cost prediction on a chunk on their own
    costs.select{|c| c[1].nil?}.each do |nil_cost|
      nil_cost[0].chunk_index = current_chunk_index
      current_chunk_index += 1
    end
  end
end
