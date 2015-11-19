class Ability
  include CanCan::Ability

  attr_accessor :user, :project

  def initialize(user, project=nil)
    @user = user
    @project = project

    # Normal users can remove only themselves from a project
    can :destroy, ProjectParticipation, user_id: user.id

    if project.present?
      project_owner_permissions if project.user == user
    end
  end

  private

  def project_owner_permissions
    can :manage, project

    # Project owners can remove all users but themselves from a project
    can :destroy, ProjectParticipation, project_id: project.id
    cannot :destroy, ProjectParticipation, user_id: user.id

    can :manage, ProjectParticipation, project_id: project
  end
end
