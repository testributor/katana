class HomeController < ApplicationController
  layout :dynamic_layout

  def index
    user_signed_in? ? dashboard : front
  end

  private

  # When user is logged in we use the "dashboard" layout
  def dynamic_layout
    user_signed_in? ? "dashboard" : "front"
  end

  def dashboard
    @projects = current_user.participating_projects.
      includes(tracked_branches: { test_jobs: :test_job_files })
  end

  def front
  end
end
