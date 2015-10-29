class TestJobsController < DashboardController
  include Controllers::EnsureProject

  # Here, we use update to retry a failed test job
  def update
    @test_job = TestJob.find(params[:id])
    if @test_job.update(test_job_params)
      redirect_to :back, notice: 'Test job was successfully updated.'
    else
      render :edit
    end
  end

  # TODO : remove, not used
  def index
    @test_jobs = current_project.test_runs.find(params[:test_run_id]).test_jobs
  end

  private

  def test_job_params
    params.permit(:status)
  end
end
