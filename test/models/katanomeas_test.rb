require 'test_helper'

class KatanomeasTest < ActiveSupport::TestCase
  let(:_test_run) { FactoryGirl.create(:testributor_run) }
  let(:most_relevant_run) do
    FactoryGirl.create(:testributor_run, project: _test_run.project)
  end
  let(:number_of_jobs) { 200 }
  subject { Katanomeas.new(_test_run) }

  before do
    (1..number_of_jobs).each do |i|
      _test_run.test_jobs.build(command: "Command #{i}")
      FactoryGirl.create(:testributor_job,
        test_run: most_relevant_run, command: "Command #{i}",
        worker_command_run_seconds: rand(Katanomeas::CHUNK_COST_SECONDS))
    end
  end

  describe "assign_chunk_indexes_to_test_jobs" do
    describe "when there most_relevant_run is nil" do
      before { most_relevant_run.destroy }
      it "assigns a different chunk index to every test_job" do
        subject.assign_chunk_indexes_to_test_jobs
        _test_run.test_jobs.map(&:chunk_index).sort.must_equal (0..number_of_jobs - 1).to_a
      end
    end

    describe "when there is a most_relevant_run" do
      it "assigns chunks of CHUNK_COST_SECONDS seconds" do
        subject.assign_chunk_indexes_to_test_jobs

        chunk_cost_deviation = _test_run.test_jobs.group_by{ |j| j.chunk_index }.
          map do |index, group|
            total_cost = group.inject(0) do |sum, job|
              sum + job.most_relevant_job.avg_worker_command_run_seconds
            end

            (total_cost - Katanomeas::CHUNK_COST_SECONDS).abs
          end.sort[0..-2] # Skip the smallest chunk which might be too small

        # The rest should not deviate more than 50% from the target cost
        (chunk_cost_deviation.map(&:to_f).max < Katanomeas::CHUNK_COST_SECONDS / 2.0).
          must_equal true
      end
    end
  end
end
