class TestRunsController < DashboardController
  include Controllers::EnsureProject

  before_action :set_test_run, only: [:show, :update, :destroy]

  def index
    @tracked_branch = current_user.tracked_branches.find(params[:branch_id])
  end

  def show
    @run = TestRun.find(params[:id])
    @test_jobs = @run.test_jobs.order("status DESC, started_at ASC, id ASC")
  end

  # TODO : remove, not used
  def create
    @test_run = TestRun.new(test_run_params)
    @test_run.build_test_jobs
    if @test_run.save
      redirect_to @test_run, notice: 'Test run was successfully created.'
    else
      render :new
    end
  end

  def update
    if @test_run.update(test_run_params)
      redirect_to :back, notice: 'Test run was successfully updated.'
    else
      render :edit
    end
  end

  # TODO : remove, not used
  def destroy
    @test_run.destroy
    redirect_to project_branch_test_runs_url(current_project, @test_run.tracked_branch_id),
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
