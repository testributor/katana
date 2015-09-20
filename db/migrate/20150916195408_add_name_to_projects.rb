class AddNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :name, :string, null: false, default: '', index: true
  end
end
