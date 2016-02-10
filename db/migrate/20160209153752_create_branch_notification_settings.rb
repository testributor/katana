class CreateBranchNotificationSettings < ActiveRecord::Migration
  def change
    create_table :branch_notification_settings do |t|
      t.belongs_to :project_participation, index: true, null: false
      t.belongs_to :tracked_branch, index: true
      t.integer :notify_on, null: false, default: 0

      t.timestamps
    end

    add_column :projects_users, :new_branch_notify_on, :integer,
      null: false, default: 0
  end
end
