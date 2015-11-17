class DashboardController < ApplicationController
  layout "dashboard"
  before_filter :authenticate_user!
  before_filter :check_for_active_providers, except: [:create, :destroy]

  def index
    @projects = current_user.participating_projects.
      includes(tracked_branches: { test_runs: :test_jobs })
  end

  protected

  def check_for_active_providers
    unless current_user.connected_to_github?
      flash.now[:alert] =
        "Your Testributor account is not connected to GitHub anymore. "\
        "Please #{view_context.link_to 're-connect', view_context.github_oauth_authorize_url}.".
          html_safe
    end
  end
end
