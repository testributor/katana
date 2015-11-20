class TrackedBranchesController < DashboardController
  include Controllers::EnsureProject

  # TODO : Redirect to "connect your github account" page
  # when github_client doesn't exist
  def new
    if client = current_user.github_client
      branch_names_to_reject = current_project.
        tracked_branches.map(&:branch_name)
      @branches = client.
        branches(current_project.repository_id).reject do |branch|
          branch.name.in?(branch_names_to_reject)
        end.map { |b| TrackedBranch.new(branch_name: b.name) }
    end
  end

  def create
    tracked_branch = current_project.
      tracked_branches.create(branch_name: params[:branch_name])

    if tracked_branch.invalid?
      flash[:alert] = tracked_branch.errors.values.join(', ')
      redirect_to project_path(current_project) and return
    end

    build_success = tracked_branch.build_test_run_and_jobs
    if build_success && tracked_branch.save
      flash[:notice] =
        "Successfully started tracking" +
        "'#{tracked_branch.branch_name}' branch."
    elsif build_success.nil?
      # TODO : Add these as validations in model
      flash[:alert] = "#{tracked_branch.branch_name} doesn't exist " +
      "anymore on github"
    else
      flash[:alert] = tracked_branch.errors.values.join(', ')
    end

    redirect_to project_path(current_project)
  end

  private

  def github_client
    current_user.github_client
  end

  def branch_params
    params.require(:tracked_branch).permit(:branch_name)
  end
end
