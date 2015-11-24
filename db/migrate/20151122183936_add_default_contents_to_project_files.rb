class AddDefaultContentsToProjectFiles < ActiveRecord::Migration
  def up
    change_column :project_files, :contents, :string, null: false, default: ''
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
