class ProjectParticipation < ActiveRecord::Base
  self.table_name = :projects_users

  belongs_to :project
  belongs_to :user
  has_many :branch_notification_settings, dependent: :destroy

  after_create :create_branch_notification_settings
  after_destroy :remove_invitation_if_any

  accepts_nested_attributes_for :branch_notification_settings

  private

  def remove_invitation_if_any
    project.user_invitations.where(user: user).each(&:destroy)
  end

  def create_branch_notification_settings
    project.tracked_branches.each do |branch|
      self.branch_notification_settings.create!(
        tracked_branch: branch,
        notify_on: self.new_branch_notify_on)
    end
  end
end
