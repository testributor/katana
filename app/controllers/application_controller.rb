class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_redirect_url_in_cookie
  layout 'application_layout'

  helper_method :current_project

  # When project_id is set in params, set current_project if current_user
  # is a participant. If project is specified with a different name
  # (as in ProjectsController with :id), this method should be overridden.
  def current_project(param_name=:project_id)
    @current_project ||=
      params[param_name] &&
      current_user.participating_projects.find_by(id: params[param_name])
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  protected

  def set_redirect_url_in_cookie
    cookies[:redirect_to_url] = request.url
  end
end
