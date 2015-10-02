# TODO: DashboardController already defines the "show" action which means
# that if we forget to (or don't want to) create a show action, that one will
# be called. Fix this by renaming the action in DashboardController moving that
# in a child controller.
class TestJobFilesController < DashboardController
  include Controllers::EnsureProject

  # Here, we use update to retry a failed
  # test job file
  def update
    @test_job_file = TestJobFile.find(params[:id])
    if @test_job_file.update(test_job_file_params)
      redirect_to :back, notice: 'Test job file was successfully updated.'
    else
      render :edit
    end
  end

  def index
    @test_job_files =
      current_project.test_jobs.find(params[:test_job_id]).test_job_files
  end

  private

  def test_job_file_params
    params.permit(:status)
  end
end
