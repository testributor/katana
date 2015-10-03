class ApiController < ActionController::Base
  before_action :doorkeeper_authorize!

  private

  def current_project
    @current_project ||= doorkeeper_token.application.owner
  end
end
