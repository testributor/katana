class RemoveNotifyOnManualBuildsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :notify_on_manual_builds
  end

  def down
    add_column :users, :notify_on_manual_builds, :boolean, default: true
  end
end
