class TestJobsController < DashboardController
  include Controllers::EnsureProject

  def retry
    @test_job = TestJob.find(params[:test_job_id])
    @test_job.retry!
    redirect_to :back, notice: 'Test job was successfully updated.'
  end
end
