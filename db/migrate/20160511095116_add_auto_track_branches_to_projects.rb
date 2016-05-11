class AddAutoTrackBranchesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :auto_track_branches, :boolean, null: false, default: true
  end
end
