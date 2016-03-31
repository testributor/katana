class RemoveProjectWizardColumns < ActiveRecord::Migration
  def change
    drop_table :project_wizards
    remove_column :technology_selections, :project_wizard_id
  end
end
