class AddMoreNotificationSettingsOnProjectParticipations < ActiveRecord::Migration
  def change
    add_column :projects_users, :my_builds_notify_on, :integer, default: 0, null: false
    add_column :projects_users, :others_builds_notify_on, :integer, default: 0, null: false
  end
end
