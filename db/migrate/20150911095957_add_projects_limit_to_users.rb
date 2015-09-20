class AddProjectsLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :projects_limit, :integer, null: false, default: 0
  end
end
