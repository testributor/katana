class ProjectParticipation < ActiveRecord::Base
  self.table_name = :projects_users

  belongs_to :project
  belongs_to :user
  has_many :branch_notification_settings, dependent: :destroy

  validate :initiator_settings_valid

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

  def initiator_settings_valid
    invalid_setting =
      BranchNotificationSetting::NOTIFY_ON_MAP.invert[:status_change]
    if my_builds_notify_on == invalid_setting
      errors.add(:my_builds_notify_on, :invalid_option)
    end
    if others_builds_notify_on == invalid_setting
      errors.add(:others_builds_notify_on, :invalid_option)
    end
  end
end
