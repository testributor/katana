class CreateProjectWizards < ActiveRecord::Migration
  def change
    create_table :project_wizards do |t|
      t.references :user, index: true, null: false
      t.string :repo_name
      t.text :branch_names, array: true, default: []
      t.text :testributor_yml
      t.text :selected_technologies, array: true, default: []
      t.timestamps
    end
  end
end
