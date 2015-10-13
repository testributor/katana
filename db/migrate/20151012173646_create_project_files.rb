class CreateProjectFiles < ActiveRecord::Migration
  def change
    create_table :project_files do |t|
      t.belongs_to :project
      t.string :path, null: false
      t.text :contents, null: false

      t.timestamps
    end
  end
end
