class RemoveColumnsFromProjectWizard < ActiveRecord::Migration
  def up
    remove_column :project_wizards, :branch_names
    remove_column :project_wizards, :selected_technologies
    remove_column :project_wizards, :docker_image_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
