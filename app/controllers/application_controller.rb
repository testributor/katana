class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_redirect_url_in_cookie

  helper_method :current_project

  # When project_id is set in params, set current_project if current_user
  # is a participant. If project is specified with a different name
  # (as in ProjectsController with :id), this method should be overridden.
  def current_project(param_name=:project_id)
    @current_project ||=
      params[param_name] &&
      current_user.participating_projects.find_by(id: params[param_name])
  end

  protected

  def set_redirect_url_in_cookie
    cookies[:redirect_to_url] = request.url
  end

  # https://github.com/scambra/devise_invitable#controller-filter
  # raise 404 if project does not exists or current_user is not the owner
  # Since we don't show the link to create invitation to non owners, if
  # a users ends up seeing this, it means he messed with the POST params.
  def authenticate_inviter!
    current_user.projects.find(current_project.try(:id))
  end
end
