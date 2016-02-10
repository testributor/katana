class BranchNotificationSetting < ActiveRecord::Base

  NOTIFY_ON_MAP = {
    0 => "On status change",
    1 => "Always",
    2 => "Never",
    3 => "On every failure"
  }

  belongs_to :tracked_branch
  belongs_to :project_participation
  has_one :project, through: :project_participation
  has_one :user, through: :project_participation
end
