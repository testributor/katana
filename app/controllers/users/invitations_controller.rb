class Users::InvitationsController < Devise::InvitationsController
  include Controllers::EnsureProject

  before_action :authenticate_user!
  before_action :ensure_project_exists!, except: [:edit, :update]

  private

  # this is called when accepting invitation
  # should return an instance of resource class
  def accept_resource
    user = resource_class.accept_invitation!(update_resource_params)
    user.participating_projects << user.invited_by

    user
  end

  def after_invite_path_for(resource_name)
    project_path(current_project)
  end

  def current_project
    super(:id)
  end
end
