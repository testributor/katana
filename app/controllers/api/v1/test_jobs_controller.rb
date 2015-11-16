module Api
  module V1
    class TestJobsController < ApiController
      # PATCH test_jobs/bind_next_pending
      # To avoid race conditions, the selected job should be marked as running
      # in an atomic operation.
      # http://stackoverflow.com/questions/11532550/atomic-update-select-in-postgres
      def bind_next_pending
        preferred_job_sql = current_project.test_jobs.pending.
          where(test_runs: { status: [TestStatus::RUNNING,TestStatus::PENDING] }).
          order("test_runs.status DESC").limit(1).to_sql # Prefer "running" runs

        sql = <<-SQL
          UPDATE test_jobs SET status = #{TestStatus::RUNNING}
          FROM (#{preferred_job_sql} FOR UPDATE) t
          WHERE test_jobs.id = t.id
          RETURNING test_jobs.*
        SQL

        render json: TestJob.find_by_sql(sql).first, include: "test_run.project"
      end

      def update
        # TODO: only update running jobs?
        job = current_project.test_jobs.running.find(params[:id])

        # TODO: Store total_time
        if job.update(test_job_params.merge(completed_at: Time.current))
          head 200
        else
          render json: { error: job.errors.full_messages.join(', ') }
        end
      end

      private

      def test_job_params
        new_params = params.require(:test_job).permit(:result, :failures,
          :errors, :failures, :count, :assertions, :skips, :total_time, :status)

        # TODO: Remove this when we store total_time
        new_params.delete(:total_time)

        # Replace "errors" with "test_errors" because we can't have an
        # errors attribute (it conflicts with ActiveRecord's errors method)
        if errors = new_params.delete(:errors)
          new_params.merge(test_errors: errors)
        else
          new_params
        end
      end
    end
  end
end
