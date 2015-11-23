class DashboardController < ApplicationController
  rescue_from Octokit::Unauthorized, with: :redirect_reconnect_to_github
  layout "dashboard"
  before_filter :authenticate_user!
  before_filter :check_for_active_providers, except: [:create, :destroy]

  def index
    @projects = current_user.participating_projects.
      includes(tracked_branches: { test_runs: :test_jobs })
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_project)
  end

  protected

  def check_for_active_providers
    unless current_user.connected_to_github?
      flash.now[:alert] = reconnect_message
    end
  end

  def redirect_reconnect_to_github
    if request.xhr?
      render text: reconnect_message and return
    end
    path = request.env['PATH_INFO']
    if path != root_path
      flash[:alert] = reconnect_message.html_safe
      redirect_to root_path and return
    end
  end

  private

  def reconnect_message
    "Your Testributor account is not connected to GitHub anymore. "\
    "Please #{view_context.link_to 're-connect', view_context.github_oauth_authorize_url}.".
      html_safe
  end
end
