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
    end
  end
end
