class TestRunsController < DashboardController
  include Controllers::EnsureProject

  before_action :set_test_run, only: [:show, :update, :destroy, :retry]

  def index
    @tracked_branch = current_user.tracked_branches.find(params[:branch_id])
  end

  def show
    @run = TestRun.find(params[:id])
    @test_jobs = @run.test_jobs.order("status DESC, started_at ASC, id ASC")
  end

  def create
    branch = TrackedBranch.find(params[:branch_id])
    branch.create_test_run_and_jobs!

    redirect_to :back, notice: 'Your build was added to queue'
  end

  def update
    if @test_run.update(test_run_params)
      redirect_to :back, notice: 'Test run was successfully updated.'
    else
      render :edit
    end
  end

  def retry
    @test_run.test_jobs.destroy_all
    @test_run.build_test_jobs
    @test_run.save
    redirect_to :back, notice: 'Test run was successfully updated.'
  end

  def destroy
    tracked_branch_id = @test_run.tracked_branch_id
    @test_run.destroy
    redirect_to project_branch_test_runs_url(current_project, tracked_branch_id),
      notice: 'Test run was successfully cancelled.'
  end

  private

  def set_test_run
    @test_run = TestRun.find(params[:id])
  end

  def test_run_params
    params.permit(:status)
  end
end
