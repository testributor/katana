class Ability
  include CanCan::Ability

  attr_accessor :user, :project

  def initialize(user, project=nil)
    @user = user
    @project = project

    if @project.present?
      project_owner_permissions if @project.user = @user
    end
  end

  private

  def project_owner_permissions
    can :manage, project
    can :manage, ProjectParticipation, project_id: project
  end
end
