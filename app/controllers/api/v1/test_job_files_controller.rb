module Api
  module V1
    class TestJobFilesController < ApiController
      # PATCH test_job_files/bind_next_pending
      # To avoid race conditions, the selected file should be marked as running
      # in an atomic operation.
      # http://stackoverflow.com/questions/11532550/atomic-update-select-in-postgres
      def bind_next_pending
        preferred_file_sql = current_project.test_job_files.pending.
          where(test_jobs: { status: [TestStatus::RUNNING,TestStatus::PENDING] }).
          order("test_jobs.status DESC").limit(1).to_sql # Prefer running jobs

        sql = <<-SQL
          UPDATE test_job_files SET status = #{TestStatus::RUNNING}
          FROM (#{preferred_file_sql} FOR UPDATE) t
          WHERE test_job_files.id = t.id
          RETURNING test_job_files.*
        SQL

        render json: TestJobFile.find_by_sql(sql).first, include: "test_job.project"
      end

      def update
        # TODO: only update running files?
        file = current_project.test_job_files.running.find(params[:id])

        # TODO: Change status to either FAIL or SUCCESS (or ERROR ?)
        # TODO: Store total_time
        if file.update(test_job_file_params.merge(completed_at: Time.current,
            status: TestStatus::COMPLETE))
          head 200
        else
          render json: { error: file.errors.full_messages.join(', ') }
        end
      end

      private

      def test_job_file_params
        new_params = params.require(:test_job_file).permit(:result, :failures,
          :errors, :failures, :count, :assertions, :skips, :total_time)

        # TODO: Remove this when we store total_time
        new_params.delete(:total_time)

        # Replace "errors" with "test_errors" because we can't have an
        # errors attribute (it conflicts with ActiveRecord's errors method)
        new_params.merge(test_errors: new_params.delete(:errors))
      end
    end
  end
end
