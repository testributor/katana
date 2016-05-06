class AddAutoTrackBranchesOnPushToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :auto_track_branches_on_push, :boolean, null: false, default: true
  end
end
