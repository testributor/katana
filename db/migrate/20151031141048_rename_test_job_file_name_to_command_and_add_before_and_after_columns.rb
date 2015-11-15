class RenameTestJobFileNameToCommandAndAddBeforeAndAfterColumns < ActiveRecord::Migration
  def change
    rename_column :test_jobs, :file_name, :command
    add_column :test_jobs, :before, :text, null: false, default: ''
    add_column :test_jobs, :after, :text, null: false, default: ''
  end
end
