class AddNotifyOnManualBuildsOnUsers < ActiveRecord::Migration
  def change
    add_column :users, :notify_on_manual_builds, :boolean, default: true
  end
end
