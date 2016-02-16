class CreateBranchNotificationSettingsForExistingUsers < ActiveRecord::Migration
  def up
    Project.all.each do |project|
      project.tracked_branches.each do |branch|
        project.project_participations.each do |participation|
          BranchNotificationSetting.create!(
            project_participation: participation,
            tracked_branch: branch)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
