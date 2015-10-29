class TrackedBranchesController < DashboardController
  include Controllers::EnsureProject

  def new
    if client = current_user.github_client
      @branches = client.branches(current_project.repository_id).
        reject { |b| b.name.in?(current_project.tracked_branches.map(&:branch_name)) }.
        map { |b| TrackedBranch.new(branch_name: b.name) }
    end
  end

  def create
    if branch_params[:branch_name].present? && github_client.present?
      branch = fetch_branch
      tracked_branch = current_project.
        tracked_branches.create!(branch_name: branch[:name])

      test_run = tracked_branch.
        test_runs.build(commit_sha: branch[:commit][:sha])
      test_run.build_test_jobs
      test_run.save!
      flash[:notice] =
        "Successfully started tracking '#{tracked_branch.branch_name}' branch."
    end

    redirect_to project_path(current_project)
  end

  private

  def fetch_branch
    current_user.github_client.
      branch(current_project.repository_id, branch_params[:branch_name])
  end

  def github_client
    current_user.github_client
  end

  def branch_params
    params.require(:tracked_branch).permit(:branch_name)
  end
end
