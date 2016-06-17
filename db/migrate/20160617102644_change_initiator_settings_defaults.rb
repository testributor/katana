class ChangeInitiatorSettingsDefaults < ActiveRecord::Migration
  def up
    change_column :projects_users, :my_builds_notify_on, :integer, default: 1, null: false
    change_column :projects_users, :others_builds_notify_on, :integer, default: 1, null: false

    ProjectParticipation.where(my_builds_notify_on: 0).update_all(my_builds_notify_on: 1)
    ProjectParticipation.where(others_builds_notify_on: 0).update_all(others_builds_notify_on: 1)
  end

  def down
    change_column :projects_users, :my_builds_notify_on, :integer, default: 0, null: false
    change_column :projects_users, :others_builds_notify_on, :integer, default: 0, null: false
  end
end
