class AddInDemoModeFlagToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :in_demo_mode, :boolean, default: false, null: false
  end
end
