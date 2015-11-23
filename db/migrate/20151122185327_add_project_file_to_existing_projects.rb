class AddProjectFileToExistingProjects < ActiveRecord::Migration
  def up
    Project.find_each do |project|
      project.project_files.where(path: ProjectFile::BUILD_COMMANDS_PATH).
        create!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
