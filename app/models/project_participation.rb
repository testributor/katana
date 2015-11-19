class ProjectParticipation < ActiveRecord::Base
  self.table_name = :projects_users

  belongs_to :project
  belongs_to :user

  after_destroy :remove_invitation_if_any

  private

  def remove_invitation_if_any
    project.user_invitations.where(user: user).each(&:destroy)
  end
end
