class AddRepositoryOwnerToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :repository_owner, :string, null: false, default: ''
  end
end
