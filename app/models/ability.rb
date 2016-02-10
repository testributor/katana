class Ability
  include CanCan::Ability

  attr_accessor :user, :project

  def initialize(user, project=nil)
    @user = user
    @project = project

    # Normal users can remove only themselves from a project
    can :destroy, ProjectParticipation, user_id: user.id
    can :update, ProjectParticipation, user_id: user.id

    if project.present?
      project_owner_permissions if project.user == user
    end

    live_updates_permissions
  end

  private

  def project_owner_permissions
    can :manage, project

    # Project owners can remove all users but themselves from a project
    can :manage, ProjectParticipation, project_id: project.id
    cannot :destroy, ProjectParticipation, user_id: user.id
  end

  def live_updates_permissions
    can :read_live_updates, TestJob do |test_job|
      test_job.test_run.project.members.include?(user)
    end

    can :read_live_updates, TestRun do |test_run|
      test_run.project.members.include?(user)
    end

    can :read_live_updates, Project do |project|
      project.members.include?(user)
    end
  end
end
