class AddProjectIdToProjectWizards < ActiveRecord::Migration
  def change
    add_column :project_wizards, :project_id, :integer
  end
end
