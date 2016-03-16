class UsersApiController < ActionController::Base
  before_action :doorkeeper_authorize!
  before_action :ensure_user!

  private

  def current_user
    # When password credentials flow is used, there is no associated application.
    # The owner derives directly from the generated token.
    # TODO: Is this correct or we failed to assign the application at token
    # generation?
    unless doorkeeper_token.application
      @current_user ||= User.find(doorkeeper_token.resource_owner_id)
    end
  end

  def ensure_user!
    head :unauthorized unless current_user
  end
end
