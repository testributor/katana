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

      c = branch[:commit]
      test_run = tracked_branch.test_runs.build(
        commit_sha: c.sha,
        commit_message: c.commit.message,
        commit_timestamp: c.commit.committer.date,
        commit_url: c.html_url,
        commit_author_name: c.commit.author.name,
        commit_author_email: c.commit.author.email,
        commit_author_username: c.author.login,
        commit_committer_name: c.commit.committer.name,
        commit_committer_email: c.commit.committer.email,
        commit_committer_username: c.committer.login
      )
      if (result = test_run.build_test_jobs).is_a?(Hash)
        flash[:alert] = result[:errors]
      elsif result.nil?
        flash[:alert] = "No #{TestRun::JOBS_YML_PATH} file found!"
      else
        test_run.save!
        flash[:notice] =
          "Successfully started tracking '#{tracked_branch.branch_name}' branch."
      end
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
